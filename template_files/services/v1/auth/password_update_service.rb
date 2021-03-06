module Services
  module V1
    module Auth
      class PasswordUpdateService < BaseActionService

        action_name :update_password

        attr_reader :user

        delegate :name, to: :user, prefix: :user, allow_nil: true

        def initialize(user, options={})
          super(options)
          @user = user
        end

        private
        def execute_service_action
          unless @user.update_password(new_password_value)
            unprocessable_entity_error(@user.errors)
          end
        end

        def new_password_value
          @options[:password]
        end

        def user_can_execute_action?
          unless valid_token?
            return not_found_error!(%s(users.invalid_password_update_token))
          end

          unless valid_user?
            return not_found_error!(%s(users.not_found))
          end

          unless confirmation_match?
            return unprocessable_entity_error!(%s(users.password_combination_dont_match))
          end

          return true
        end

        def valid_token?
          return false if reset_password_token.blank?

          @token ||= User.find_by(reset_password_token: reset_password_token).try(:reset_password_token)

          return @token.present? && @user.try(:reset_password_token) == @token
        end

        def confirmation_match?
          return false if @options[:password].blank? || @options[:password_confirmation].blank?

          return @options[:password] == @options[:password_confirmation]
        end

        def after_success
          notify_users
        end

        def notify_users
          delivery_async_email(UsersMailer, :password_updated, user_id: @user.id)
          send_push_notification_sync(@user, :password_updated)
          create_system_notification_async(@user, :password_updated, @user, @options)
        end

        def reset_password_token
          @options[:token]
        end
      end
    end
  end
end
