require 'test_helper'
require_relative 'base_controller_test'

module Folio
  class Console::MenusControllerTest < Folio::Console::BaseControllerTest
    setup do
      @menu = create(:menu_with_menu_items)
    end

    test 'should get index' do
      get console_menus_url
      assert_response :success
    end

    test 'should get new' do
      get new_console_menu_url
      assert_response :success
    end

    test 'should get edit' do
      get edit_console_menu_url(@menu)
      assert_response :success
    end
  end
end
