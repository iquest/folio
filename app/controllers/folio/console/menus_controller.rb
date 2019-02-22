# frozen_string_literal: true

class Folio::Console::MenusController < Folio::Console::BaseController
  folio_console_controller_for 'Folio::Menu'

  def create
    @menu = Folio::Menu.create(menu_params)
    respond_with @menu
  end

  def update
    @menu.update(menu_params)
    respond_with @menu, location: { action: :edit }
  end

  def destroy
    @menu.destroy
    respond_with @menu
  end

  def show
    fail ActionController::MethodNotAllowed unless @menu.supports_nesting?
  end

  def tree_sort
    @menu.transaction do
      params.require(:sortable).each do |index, menu_item|
        next if menu_item[:id].blank?
        @menu.menu_items.find(menu_item[:id])
                        .update!(parent_id: menu_item[:parent_id],
                                 position: index)
      end
    end
  end

  private

    def menu_params
      sti_menu_items(
        params.require(:menu)
              .permit(:type,
                      :locale,
                      menu_items_attributes: menu_items_attributes)
      )
    end

    def menu_items_attributes
      [
        :id,
        :title,
        :target,
        :position,
        :type,
        :rails_path,
        :_destroy,
      ]
    end

    def sti_menu_items(params)
      sti_hack(params, :menu_items_attributes, :target)
    end
end
