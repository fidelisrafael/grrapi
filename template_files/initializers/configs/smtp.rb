Rails.application.configure do
  _Config = Application::Config

  config.action_mailer.delivery_method = :letter_opener

  smtp_username = ENV['SENDGRID_USERNAME'] || _Config.smtp_username
  smtp_password = ENV['SENDGRID_PASSWORD'] || _Config.smtp_password
  smtp_host     = ENV['SENDGRID_HOST']     || _Config.smtp_host
  smtp_port     = ENV['SENDGRID_PORT']     || _Config.smtp_port
  smtp_domain   = ENV['SENDGRID_DOMAIN']   || _Config.smtp_domain

  if [smtp_username, smtp_password, smtp_host, smtp_port, smtp_domain].all?

    config.action_mailer.delivery_method = :smtp

    config.action_mailer.smtp_settings = {
      :port           => smtp_port,
      :address        => smtp_host,
      :user_name      => smtp_username,
      :password       => smtp_password,
      :domain         => smtp_domain,
      :authentication => :login,
      :enable_starttls_auto => true
    }
  end
end
