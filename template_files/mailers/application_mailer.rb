class ApplicationMailer < ActionMailer::Base
  default from: Application::Config.contact_email

  layout 'mailer'
end
