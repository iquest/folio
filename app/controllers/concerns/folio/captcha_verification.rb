module Folio
  module CaptchaVerification
    extend ActiveSupport::Concern
    private
    def check_recaptcha_if_needed(model)      
      if ENV['RECAPTCHA_SITE_KEY'].present? &&
        ENV['RECAPTCHA_SECRET_KEY'].present? &&       
        model.verified_captcha = verify_recaptcha(model: model)
      end

      model
    end
  end
end