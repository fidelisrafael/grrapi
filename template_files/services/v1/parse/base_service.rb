module Services
  module V1
    module Parse
      class BaseService < ::Services::BaseService

        include ::Services::CreateServiceExtensions

        attr_reader :user

        def initialize(user, options = {})
          @user = user
          super(options)
        end

        private
        def register_device_in_parse(device)
          if Application::Config.enabled?(:save_user_device_async)
            ::Workers::V1::ParseDeviceSaveWorker.perform_async(device.id)
          else
            ::Workers::V1::ParseDeviceSaveWorker.new.perform(device.id)
          end
        end

        def channels_for_device(device)
          user = device.user
          user.channels_for_notification(device)
        end

        def parse_client
          @parse_client ||= Application::Config.parse_client
        end
      end
    end
  end
end
