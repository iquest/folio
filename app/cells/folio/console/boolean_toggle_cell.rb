# frozen_string_literal: true

class Folio::Console::BooleanToggleCell < Folio::ConsoleCell
  include SimpleForm::ActionViewExtensions::FormHelper

  class_name 'f-c-boolean-toggle', :show_label

  def show
    if attribute.present? && url.present?
      form { |f| input(f) }
    end
  end

  def form(&block)
    opts = {
      url: url,
      html: { class: class_name, id: nil },
    }

    simple_form_for(model, opts, &block)
  end

  def input(f)
    input_html = { class: 'f-c-boolean-toggle__input', id: id }

    input_html[:checked] = true if input_checked?

    f.input(attribute, wrapper: :custom_boolean_switch,
                       label: "<span>#{input_label}</span>".html_safe,
                       hint: false,
                       as: :boolean,
                       input_html: input_html)
  end

  def attribute
    options[:attribute]
  end

  def url
    controller.url_for([:console, model, format: :json])
  rescue StandardError
    nil
  end

  def id
    "f-c-boolean-toggle--#{model.id}-#{attribute}"
  end

  def input_label
    if options[:show_label]
      "#{options[:show_label]}:"
    else
      ''
    end
  end

  def input_checked?
  end
end
