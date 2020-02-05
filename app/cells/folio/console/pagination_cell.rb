# frozen_string_literal: true

class Folio::Console::PaginationCell < Folio::ConsoleCell
  include Pagy::Frontend

  def show
    render if model.present? && model.pages > 1
  end

  def link
    @link ||= pagy_link_proc(model)
  end

  def icon(code)
    %{<span class="f-c-pagination__ico fa fa-#{code}"></span>}.html_safe
  end
end
