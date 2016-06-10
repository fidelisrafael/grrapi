module Services
  class BaseService < ::SimpleServices::BaseService
  end
  class BaseCrudService < ::SimpleServices::BaseCrudService
  end
end

class SimpleServices::BaseCreateService

  WHITELIST_ORIGIN_PARAMS = [:provider, :locale, :user_agent, :ip]

  def origin_params(params={})
    origin_data = (params.is_a?(Hash) && params.present? ? params : @options)[:origin] || {}
    origin_data.slice(*WHITELIST_ORIGIN_PARAMS)
  end

  def create_origin(originable, params = {})
    return unless originable.respond_to?(:create_origin)

    originable.create_origin(origin_params(params))
  end

  def create_origin_async(originable, params = {})
    create_origin(originable, params)
  end
end

SimpleServices::BaseCreateService.register_callback(:after_success, :create_origin_for_record) do
  create_origin_async(@record, @options)
end

module SimpleServices
  class BaseCrudService < BaseCrudService.superclass
    def self.services_concern_namespace
      "Services::V1"
    end
  end
end

[:BaseService, :BaseCrudService].each do |service|
  klasses = ["Services::#{service}", "SimpleServices::#{service}"].each do |klass|
    klass.constantize.class_eval do
      def valid_user?
        valid_object?(@user, User)
      end
    end
  end
end
