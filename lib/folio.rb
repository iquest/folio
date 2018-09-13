# frozen_string_literal: true

require 'kaminari'

require 'dotenv-rails'
require 'folio/engine'
require 'friendly_id'
require 'ancestry'
require 'devise'
require 'cancancan'
require 'responders'
require 'active_model_serializers'
require 'sitemap_generator'
require 'acts-as-taggable-on'
require 'pg_search'

require 'cells'
require 'cells-rails'
require 'cells-slim'
require 'slim'
require 'sass-rails'
require 'bootstrap'
require 'simple_form'
require 'cocoon'
require 'kaminari'
require 'font-awesome-rails'
require 'jquery-rails'
require 'dropzonejs-rails'
require 'countries'
require 'breadcrumbs_on_rails'
require 'rails-assets-selectize'
require 'ahoy_matey'
require 'invisible_captcha'
require 'rails-i18n'
require 'state_machines'
require 'state_machines-activerecord'

module Folio
  class Engine < ::Rails::Engine
    config.assets.precompile += %w[
      folio/console/base.css
      folio/console/base.js
      folio/console/react/main.js
      folio/console/react/main.css
    ]

    config.folio_dragonfly_keep_png = false
    config.folio_public_page_title_reversed = false
  end

  LANGUAGES = {
    cs: 'CZ',
    de: 'DE',
    es: 'ES',
    en: 'GB'
  }

  EMAIL_REGEXP = /[^@]+@[^@]+/
  OG_IMAGE_DIMENSIONS = '1200x630#'
end
