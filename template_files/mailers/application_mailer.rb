class ApplicationMailer < ActionMailer::Base
  default from: Application::Config.from_contact_email

  layout 'mailer'

  def admin_contact_email
    Application::Config.from_contact_email
  end
end
