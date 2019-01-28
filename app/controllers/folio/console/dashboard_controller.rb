# frozen_string_literal: true

module Folio
  class Console::DashboardController < Console::BaseController
    def index
      if path = Rails.application.config.folio_console_dashboard_redirect
        if respond_to?(path)
          redirect_to send(path)
        elsif main_app.respond_to?(path)
          redirect_to main_app.send(path)
        end
      end
    end
  end
end
