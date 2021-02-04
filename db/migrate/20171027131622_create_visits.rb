# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration[5.1]
  def change
    if defined?(Ahoy) && !table_exists?(:visits)
      create_table :visits do |t|
        t.string :visit_token
        t.string :visitor_token

        # the rest are recommended but optional
        # simply remove the columns you don't want

        # standard
        t.string :ip
        t.text :user_agent
        t.text :referrer
        t.text :landing_page

        # site
        t.belongs_to :site

        # user
        t.belongs_to :account
        # add t.string :user_type if polymorphic

        # traffic source
        t.string :referring_domain
        t.string :search_keyword

        # technology
        t.string :browser
        t.string :os
        t.string :device_type
        t.integer :screen_height
        t.integer :screen_width

        # location
        t.string :country
        t.string :region
        t.string :city
        t.string :postal_code
        t.decimal :latitude
        t.decimal :longitude

        # utm parameters
        t.string :utm_source
        t.string :utm_medium
        t.string :utm_term
        t.string :utm_content
        t.string :utm_campaign

        # native apps
        # t.string :platform
        # t.string :app_version
        # t.string :os_version

        t.timestamp :started_at
      end

      add_index :visits, [:visit_token], unique: true
    end
  end
end
