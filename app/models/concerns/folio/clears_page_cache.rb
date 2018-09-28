# frozen_string_literal: true

module Folio
  module ClearsPageCache
    extend ActiveSupport::Concern

    included do
      after_commit :clear_page_cache!
    end

    def clear_page_cache!
      return unless self.class.clears_page_cache_on_save?
      return unless Rails.application.config.action_controller.perform_caching
      cache_dir = Rails.application.config.action_controller.page_cache_directory
      return if cache_dir.blank? || !::File.exist?(cache_dir)
      Dir.mktmpdir { |tmp_dir| FileUtils.mv cache_dir, tmp_dir }
    end

    module ClassMethods
      # overridable
      def clears_page_cache_on_save?
        true
      end
    end
  end
end