# frozen_string_literal: true

require Folio::Engine.root.join("lib/generators/folio/generator_base")

module Folio
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ::Folio::GeneratorBase

      desc "Creates folio initializer, routes and copies locale files to your application."

      source_root Folio::Engine.root.join("lib/templates")

      def add_gems
        gem "turbolinks"
        gem "dotenv-rails"
        gem "autoprefixer-rails", "9.8.5"
        gem "slim-rails"
        gem "cells"
        gem "cells-slim", "0.0.6"
        gem "cells-rails", "0.1.0"
        gem "route_translator"
        gem "breadcrumbs_on_rails"
        gem "sentry-ruby"
        gem "devise-i18n"
        gem "rails-i18n"
        gem "mini_racer"
        gem "premailer", github: "sinfin/premailer"
        gem "premailer-rails"
        gem "rubyzip"
        gem "uglifier", ">= 1.3.0"
        gem "faker", require: false

        gem "sidekiq", "~> 5"
        gem "sidekiq-cron", "1.2.0"
        gem "sidekiq-monitoring", "1.3.4"
        gem "redis-namespace", "1.8.1"

        gem "status-page", "0.1.5"
        
        gem "rack-mini-profiler"

        gem_group :test do
          gem "factory_bot"
        end

        gem_group :development do
          gem "rbnacl", version: "< 5.0"
          gem "rbnacl-libsodium"
          gem "bcrypt_pbkdf", version: "< 2.0"
          gem "ed25519"

          gem "rubocop"
          gem "rubocop-minitest"
          gem "rubocop-performance"
          gem "rubocop-rails"
          gem "rubocop-rails_config"
          gem "rubocop-rake"
          gem "annotate"
          gem "guard-rubocop"
          gem "guard-slimlint"
          gem "letter_opener"
          gem "pry-rails"
          gem "slack-notifier"
          gem "better_errors"
          gem "binding_of_caller"
          gem "rails-flog", require: "flog"
        end
      end

      def rm_rails_new_stuff
        [
          "app/views/layouts/application.html.erb",
          "public/404.html",
          "public/422.html",
          "public/500.html",
        ].each do |path|
          full_path = Rails.root.join(path)
          ::File.delete(full_path) if ::File.exist?(full_path)
        end
      end

      def copy_templates
        [
          ".env.sample",
          "app/controllers/application_controller.rb",
          "app/controllers/errors_controller.rb",
          "app/controllers/home_controller.rb",
          "app/controllers/pages_controller.rb",
          "app/lib/application_cell.rb",
          "app/models/application_record.rb",
          "app/models/global_namespace_path.rb",
          "app/models/global_namespace_path/page/homepage.rb",
          "app/overrides/cells/folio/ui_cell_override.rb",
          "app/overrides/controllers/folio/console/api/links_controller_override.rb",
          "app/views/layouts/folio/application.slim",
          "config/database.yml",
          "config/initializers/assets.rb",
          "config/initializers/folio.rb",
          "config/initializers/namespace.rb",
          "config/initializers/raven.rb",
          "config/initializers/smtp.rb",
          "config/locales/activerecord.cs.yml",
          "config/locales/activerecord.en.yml",
          "config/routes.rb",
          "config/schedule.rb",
          "config/sitemap.rb",
          "data/atoms_showcase.yml",
          "data/seed/pages/homepage.yml",
          "db/seeds.rb",
          "lib/tasks/developer_tools.rake",
          "public/maintenance.html",
          "test/factories.rb",
          "test/test_helper.rb",
          "vendor/assets/bower.json",
        ].each { |f| template "#{f}.tt", f.gsub("global_namespace_path", global_namespace_path) }

        template ".env.sample.tt", ".env"
      end

      def copy_files
        [
          ".gitignore",
          ".rubocop.yml",
          ".slim-lint.yml",
          "app/assets/config/manifest.js",
          "app/views/devise/invitations/edit.slim",
          "app/views/folio/pages/show.slim",
          "app/views/home/index.slim",
          "bin/bower",
          "config/secrets.yml",
          "data/email_templates_data.yml",
          "Guardfile",
          "lib/tasks/auto_annotate_models.rake",
          "vendor/assets/bower_components/.keep",
          "vendor/assets/redactor/redactor.css",
          "vendor/assets/redactor/redactor.js",
        ].each { |f| copy_file f, f }

        copy_file Folio::Engine.root.join(".ruby-version"), ".ruby-version"
      end

      def mkdir_folders
        [
          ::Rails.root.join("app/cells/#{project_name}")
        ].each do |path|
          FileUtils.mkdir_p path
        end
      end

      def application_settings
        return if ::File.readlines(Rails.root.join("config/application.rb")).grep('Rails.root.join("lib")').any?

        inject_into_file "config/application.rb", after: /config\.load_defaults.+\n/ do <<-'RUBY'
    config.exceptions_app = self.routes

    config.time_zone = "Prague"

    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.test_framework :test_unit, fixture: false
    end

    I18n.available_locales = [:cs, :en]
    I18n.default_locale = :cs

    config.folio_console_locale = I18n.default_locale
    config.autoload_paths << Rails.root.join("app/lib")
    config.eager_load_paths << Rails.root.join("app/lib")

    Rails.autoloaders.main.ignore("#{::Folio::Engine.root}/app/lib/folio/console/simple_form_components")
    Rails.autoloaders.main.ignore("#{::Folio::Engine.root}/app/lib/folio/console/simple_form_inputs")

    overrides = [
      Folio::Engine.root.join("app/overrides").to_s,
      Rails.root.join("app/overrides").to_s,
    ]

    overrides.each { |override| Rails.autoloaders.main.ignore(override) }

    config.to_prepare do
      overrides.each do |override|
        Dir.glob("#{override}/**/*_override.rb").each do |file|
          load file
        end
      end
    end

        RUBY
        end
      end

      def development_settings
        gsub_file "config/environments/development.rb", /  config\.action_mailer\.raise_delivery_errors = false/ do
          [
            "config.action_mailer.raise_delivery_errors = true",
            "config.action_mailer.delivery_method = :letter_opener",
            "config.action_mailer.perform_deliveries = true",
          ].join("\n  ")
        end
      end

      def production_settings
        gsub_file "config/environments/production.rb", "config.assets.js_compressor = :uglifier", "config.assets.js_compressor = Folio::SelectiveUglifier.new(harmony: false) # change to true to use es6"
      end

      def chmod_files
        [
          "bin/bower",
        ].each do |file|
          ::File.chmod(0775, Rails.root.join(file))
        end
      end

      def run_assets_generator
        generate "folio:assets"
      end

      private
        def project_name
          @project_name ||= Rails.root.basename.to_s
        end

        def project_classnames_prefix
          project_name[0]
        end
    end
  end
end
