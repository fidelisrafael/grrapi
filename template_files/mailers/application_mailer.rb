class ApplicationMailer < ActionMailer::Base
  default from: Application::Config.from_contact_email

  layout 'mailer'

  def admin_contact_email
    Application::Config.from_contact_email
  end

  def admin_moderation_email
    Application::Config.moderation_admin_email
  end
end
