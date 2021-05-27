module Folio::CaptchaValidation
  extend ActiveSupport::Concern

  included do
    attr_accessor :verified_captcha
    validate :validate_verified_captcha
  end

  private

  def validate_verified_captcha    
    return if verified_captcha == true
    return if verified_captcha.nil?
    errors.add(:verified_captcha, :invalid)
  end
end