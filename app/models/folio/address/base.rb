# frozen_string_literal: true

class Folio::Address::Base < Folio::ApplicationRecord
  include Folio::StiPreload

  self.table_name = "folio_addresses"

  validates :address_line_1,
            :city,
            :zip,
            :country_code,
            :type,
            presence: true

  audited only: %i[address_line_1 address_line_2 city country_code name zip]

  def country
    ISO3166::Country.new(country_code)
  end

  def to_label
    [address_line_1, address_line_2].map(&:presence).compact.join(", ")
  end

  def self.sti_paths
    [
      Folio::Engine.root.join("app/models/folio/address"),
      Rails.root.join("app/models/**/address"),
    ]
  end

  def self.fields_layout
    [
      { name: 6, company_name: 6 },
      :address_line_1,
      :address_line_2,
      { city: 7, zip: 5 },
      :country_code,
      :state,
      { identification_number: 6, vat_identification_number: 6 },
      { email: 6, phone: 6 },
    ]
  end

  def self.show_for_attributes
    %i[
      name
      company_name
      address_line_1
      address_line_2
      city
      zip
      country_code
      state
      identification_number
      vat_identification_number
      phone
      email
    ]
  end

  def self.priority_countries
    []
  end

  private
    def should_validate_country_code?
      true
    end
end

# == Schema Information
#
# Table name: folio_addresses
#
#  id                        :bigint(8)        not null, primary key
#  name                      :string
#  company_name              :string
#  address_line_1            :string
#  address_line_2            :string
#  zip                       :string
#  city                      :string
#  country_code              :string
#  state                     :string
#  identification_number     :string
#  vat_identification_number :string
#  phone                     :string
#  email                     :string
#  type                      :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_folio_addresses_on_type  (type)
#
