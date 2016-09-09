NiftyServices.config do |config|
  config.service_concerns_namespace = "Services::V1::Concerns"
  config.user_class = User
  config.logger = Logger.new('log/services.log')
end

class NiftyServices::BaseService
  def full_errors_messages
    errors.map do |error_data, _|
      return Array.wrap(error_data) unless error_data.kind_of?(Enumerable)

      error_data.map do |attribute, errors|
        "#{attribute.to_s.humanize} #{errors.to_sentence}"
      end
    end.flatten
  end
end
