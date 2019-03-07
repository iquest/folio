# frozen_string_literal: true

require 'csv'

class Folio::Console::LeadsController < Folio::Console::BaseController
  folio_console_controller_for 'Folio::Lead'

  def index
    @leads = @leads.ordered.includes(:visit)

    respond_with(@leads) do |format|
      format.html do
        @pagy, @leads = pagy(@leads)
      end
      format.csv do
        data = ::CSV.generate(headers: true) do |csv|
          csv << Folio::Lead.csv_attribute_names.map { |a| Folio::Lead.human_attribute_name(a) }
          @leads.each { |lead| csv << lead.csv_attributes }
        end
        name = Folio::Lead.model_name.human(count: 2)
        filename = "#{name}-#{Date.today}.csv".split('.')
                                              .map(&:parameterize)
                                              .join('.')
        send_data data, filename: filename
      end
    end
  end

  def edit
  end

  def update
    @lead.update(lead_params)
    respond_with @lead
  end

  def destroy
    @lead.destroy
    respond_with @lead
  end

  def mass_handle
    @leads = Folio::Lead.not_handled.where(id: params.require(:leads))
    @leads.update_all(aasm_state: 'handled')
    flash.notice = t('.success')
    respond_with @leads
  end

  def index_filters
    {
      by_state: Folio::Lead.aasm.states_for_select,
    }
  end

  private

    def lead_params
      params.require(:lead)
            .permit(:aasm_state,
                    :name,
                    :email,
                    :phone,
                    :note,
                    :url,
                    :additional_data)
    end
end
