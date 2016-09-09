module Services
  module V1
    module Auth
      class PasswordRecoveryService < BaseActionService

        attr_reader :user

        action_name :recovery_password

        RESET_PASSWORD_UPDATE_PERIOD = 5.minute

        def initialize(user, options = {})
          super(options)
          @user = user
        end

        private
        def execute_service_action
          @user.reset_password!
        end

        def user_can_execute_action?
          unless valid_user?
            return not_found_error!(%s(users.not_found))
          end

          unless can_request_reset_password?
            remaining_time = remaining_time_for_new_request.next # + 1 minute
            return forbidden_error!(%s(users.cant_send_password_reset_request), remaining_time: remaining_time)
          end

          return true
        end

        def can_request_reset_password?
          return true if @user.reset_password_sent_at.blank?

          now = Time.zone.now
          return !@user.reset_password_sent_at.between?((now - RESET_PASSWORD_UPDATE_PERIOD), now)
        end

        def remaining_time_for_new_request
          remaining_seconds = ((@user.reset_password_sent_at + RESET_PASSWORD_UPDATE_PERIOD ) - Time.zone.now)

          (remaining_seconds/60).round
        end

        def after_success
          notify_users
        end

        def notify_users
          delivery_async_email(UsersMailer, :password_recovery, user_id: @user.id)
        end
      end
    end
  end
end
