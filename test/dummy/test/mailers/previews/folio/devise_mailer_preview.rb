# frozen_string_literal: true

class Folio::DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    Folio::DeviseMailer.reset_password_instructions(Folio::Account.last,
                                                    "RESET_PASSWORD_TOKEN").tap do |email|
      Premailer::Rails::Hook.perform(email)
    end
  end

  def invitation_instructions
    Folio::DeviseMailer.invitation_instructions(Folio::Account.last,
                                                "INVITATION_TOKEN").tap do |email|
      Premailer::Rails::Hook.perform(email)
    end
  end
end
