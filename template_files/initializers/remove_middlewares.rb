Rails.application.class.parent_name::Application.config do |config|
  config.middleware.delete "ActionDispatch::Static"
  config.middleware.delete "ActionDispatch::Cookies"
  config.middleware.delete "ActionDispatch::Session::CookieStore"
  config.middleware.delete "ActionDispatch::Flash"
  config.middleware.delete "Rack::MethodOverride"
end
