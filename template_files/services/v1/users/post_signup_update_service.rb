module Services
  module V1
    module Users
      class PostSignupUpdateService < BaseActionService

        action_name :post_signup_user_update

        attr_reader :user

        def initialize(user, options)
          @user = user
          super(options)
        end

        private
        def execute_service_action
          execute_actions
        end

        def user_can_execute_action?
          @user.present?
        end

        def notify_user?
          return @options[:notify_user].present?
        end

        def device_params
          @options.symbolize_keys.slice(:device) || {}
        end

        def create_user_device
          if device_params.present?
            service = Services::V1::Parse::DeviceCreateService.new(@user, device_params)
            service.execute
          end
        end

        def execute_actions
          create_user_device
          notify_user if notify_user?
        end

        def notify_user
          send_signup_email
          send_welcome_push_notification
          create_welcome_notifications
        end

        def send_signup_email
          delivery_async_email(UsersMailer, :welcome, user_id: @user.id)
        end

        def send_welcome_push_notification
          send_push_notification_sync(@user, :welcome)
        end

        def create_welcome_notifications
          create_system_notification_async(@user, :welcome, @user)
        end

        def record_error_key
          :users
        end
      end
    end
  end
end
