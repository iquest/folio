# frozen_string_literal: true

class Folio::Console::FooterCell < Folio::ConsoleCell
  def site_name
    link_to model.title, root_path, class: 'text-secondary'
  end
end