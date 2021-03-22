# frozen_string_literal: true

class Dummy::Ui::HeaderCell < ApplicationCell
  include Folio::ActiveClass
  include Folio::CstypoHelper

  MENU_INPUT_ID = "d-ui-header__menu-input"

  def menu
    @menu ||= Dummy::Menu::Header.instance(fail_on_missing: false)
  end

  def menu_url_for(menu_item)
    if menu_item.url.present?
      menu_item.url
    elsif menu_item.eager_load_aware_target.present?
      url_for(menu_item.eager_load_aware_target)
    elsif menu_item.rails_path.present?
      controller.send(menu_item.rails_path)
    end
  end

  def link_tag(menu_item, class_name, children = nil)
    tag = {
      class: class_name,
      tag: :span,
    }

    path = menu_url_for(menu_item)
    paths = path ? [path] : []

    if children.present?
      children.each do |child, _x|
        child_path = menu_url_for(child)
        paths << child_path if child_path
      end
    end

    if paths.present?
      ac = active_class(*paths, start_with: true, base: class_name)
      tag[:class] = "#{tag[:class]} #{ac}"
    end

    if children.present?
      tag[:class] = "#{tag[:class]} #{class_name}--expandable"
    elsif path
      tag[:tag] = :a
      tag[:class] = "#{tag[:class]} #{ac}"
      tag[:href] = path
      tag[:target] = menu_item.open_in_new ? "_blank" : nil
    end

    tag
  end
end
