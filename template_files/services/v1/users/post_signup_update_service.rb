module Services
  module V1
    module Users
      class SignupUpdateService < SimpleServices::BaseService

        attr_reader :user

        def initialize(user, options)
          @user = user
          super(options)
        end

        def execute
          execute_actions
          success_response
        end

        private
        def notify_user?
          return @options[:notify_user].present?
        end

        def execute_actions
          notify_user if notify_user?
        end

        def notify_user
          send_signup_email
          create_welcome_notifications
        end

        def send_signup_email
          delivery_async_email(UsersMailer, :welcome, @user)
        end

        def create_welcome_notifications
          create_system_notification_async(@user, :welcome)
        end
      end
    end
  end
end
