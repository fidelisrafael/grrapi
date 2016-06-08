require 'rollbar/rails'

Rollbar.configuration.access_token = (ENV['ROLLBAR_ACCESS_TOKEN'] || Application::Config.rollbar_access_token || '')
Rollbar.configuration.enabled = [Rails.env.staging?, Rails.env.production?].any?
