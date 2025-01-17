# frozen_string_literal: true

class Dummy::Ui::ModalCell < ApplicationCell
  def footer_button(key)
    if model[key]
      opts = { class: "btn btn-#{key} btn-xs-block #{model[:class]}__footer-btn #{model[:class]}__footer-btn--#{key}" }

      if model[key][:class].present?
        opts[:class] += " #{model[key][:class]}"
      end

      if model[key][:href]
        link_to(model[key][:label], model[key][:href], opts)
      else
        opts[:type] = :button
        if key == :secondary
          opts["data-dismiss"] = "modal"
        end

        content_tag(:button, model[key][:label], opts)
      end
    end
  end
end
