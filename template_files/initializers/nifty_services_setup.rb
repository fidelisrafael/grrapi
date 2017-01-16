NiftyServices.config do |config|
  config.service_concerns_namespace = "Services::V1::Concerns"
  config.user_class = 'User'
  config.logger = Logger.new('log/services.log')
end