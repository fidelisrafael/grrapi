# Don't use NiftyServices direct as father class, so we can
# add custom code to application services

module Services
  module CreateServiceExtensions
    ORIGIN_WHITELIST_ATTRIBUTES = [
      :provider, :locale, :user_agent, :ip
    ]

    def origin_params(params = {})
      # grape uses Mashie::Hash for params manipulation
      origin_data = (params.is_a?(Hash) && params.present? ? params : @options).fetch(:origin, {}).to_h

      filter_hash(origin_data, ORIGIN_WHITELIST_ATTRIBUTES)
    end

    def create_origin(originable, params = {})
      return unless originable.respond_to?(:create_origin)

      return create_origin_async(originable, params) if create_origin_async?

      originable.create_origin(origin_params(params))
    end

    def create_origin_async(originable, params = {})
      return nil unless create_origin?

      worker_options = {
        fetch_originable: false
      }

      origin_params = origin_params(params).merge(originable_id: originable.id,
                                                  originable_type: originable.class.to_s)

      Workers::V1::OriginCreateWorker.perform_async( worker_options.merge(origin: origin_params) )
    end

    def create_origin?
      Application::Config.enabled?(:create_origin_for_records)
    end

    def create_origin_async?
      Application.config.enabled?(:create_origins_async)
    end
  end

  class BaseCreateService < ::NiftyServices::BaseCreateService
    include CreateServiceExtensions

    def on_save_record_error(error)
      options = {}

      # force backtrace to be added in error message
      if Rails.env.development? || Rails.env.staging?
        options[:translate] = false
        error = error.class.new("#{error.message}\n#{error.backtrace}")
      end

      return unprocessable_entity_error!(error, options)
    end
  end

  class BaseActionService < ::NiftyServices::BaseActionService
    include CreateServiceExtensions
  end

  BaseCreateService.register_callback(:after_success, :create_origin_for_record) do
    create_origin_async(@record, @options)
  end
end