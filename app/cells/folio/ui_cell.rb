# frozen_string_literal: true

class Folio::UiCell < Folio::ApplicationCell
  include SimpleForm::ActionViewExtensions::FormHelper
  include ActionView::Helpers::FormOptionsHelper
  include Pagy::Backend

  def show
    if model.present?
      @mobile_only = true
      render(:_typo)
    else
      render
    end
  end

  def main_colors
    %w[blue primary]
  end

  def additional_colors
    %w[light-gray medium-gray gray dark-gray blue red purple green orange yellow]
  end

  def button_variants
    %w[primary secondary]
  end

  def button_sizes
    [nil, "btn-sm", "btn-lg"]
  end

  def global_namespace
    @global_namespace ||= ::Rails.application.class.name.deconstantize
  end

  def global_namespace_path
    @global_namespace_path ||= global_namespace.underscore
  end

  def pagy_model
    pagy, _pages = pagy(Folio::Page.all, items: 1)
    pagy
  end

  def tabs_model
    [
      { href: "#", active: true, label: "Current tab" },
      { href: "#", label: "Another tab" },
      { href: "#", label: "Another tab" },
    ]
  end

  def missing_cell(cell_key)
    content_tag(:p,
                "No #{cell_key} cell. Run <code>rails g folio:ui #{cell_key}</code> to create one.",
                class: "text-danger")
  end

  def icons
    path = ::Rails.root.join("app/assets/stylesheets/_icons.scss")

    if File.exist?(path)
      str = File.read(path)
      str.scan(/^.+-ui-icon--.+:before/).to_a.map do |selector|
        selector.gsub(/:.*$/, "").gsub(/^\./, "").split("--")
      end
    end
  end

  def flash_models
    %i[notice success warning alert].map do |key|
      flash_hash = ActionDispatch::Flash::FlashHash.new
      flash_hash[key] = key
      flash_hash
    end
  end
end
