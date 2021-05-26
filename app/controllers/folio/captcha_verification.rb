module CaptchaVerification
  extend ActiveSupport::Concern
  private
    def check_recaptcha_if_needed(model)
      if ENV['RECAPTCHA_SITE_KEY'].present? &&
        ENV['RECAPTCHA_SECRET_KEY'].present? &&       
        result = verify_recaptcha(model: model)
        model.verified_captcha = result
      end

      model
    end

end