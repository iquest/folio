# frozen_string_literal: true

class Folio::NewsletterSubscription < Folio::ApplicationRecord
  attr_accessor :verified_captcha

  belongs_to :visit, optional: true

  # Validations
  validates_format_of :email, with: Folio::EMAIL_REGEXP

  validate :validate_verified_captcha

  # Scopes
  default_scope { order(created_at: :desc) }

  pg_search_scope :by_query,
                  against: %i[email],
                  ignoring: :accents,
                  using: {
                    tsearch: { prefix: true }
                  }

  def title
    email
  end

  def self.clears_page_cache_on_save?
    false
  end

  private
    def validate_verified_captcha
      return if verified_captcha == true
      return if verified_captcha.nil?
      errors.add(:verified_captcha, :invalid)
    end
end

# == Schema Information
#
# Table name: folio_newsletter_subscriptions
#
#  id         :bigint(8)        not null, primary key
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  visit_id   :bigint(8)
#
# Indexes
#
#  index_folio_newsletter_subscriptions_on_visit_id  (visit_id)
#
