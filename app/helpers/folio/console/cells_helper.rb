# frozen_string_literal: true

# syntactic sugar for cells
module Folio
  module Console::CellsHelper
    def featured_toggle(model, options = {})
      cell('folio/console/featured_toggle', model, options).show.html_safe
    end

    def published_toggle(model, options = {})
      cell('folio/console/published_toggle', model, options).show.html_safe
    end

    def nested_model_controls(model, options = {})
      cell('folio/console/nested_model_controls', model, options).show.html_safe
    end
  end
end
