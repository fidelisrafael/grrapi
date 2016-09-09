module Services
  module V1
    module Users
      class ActivateAccountMailerDeliveryService < BaseActionService

        INTERVAL_TO_SEND_ANOTHER_MAIL = (
          Application::Config.seconds_to_wait_between_account_activation_mail_resend || 2.minutes
        ).to_i

        action_name :send_account_activation_mail

        attr_reader :user

        def initialize(user, options = {})
          @user = user
          super(options)
        end

        private
        def execute_service_action
          send_account_activation_mail!
        end

        def user_can_execute_action?
          unless valid_user?
            return not_found_error!(%s(users.not_found))
          end

          unless can_request_mail_delivery?
            remaining_time = remaining_time_for_new_request.next # + 1 minute

            return forbidden_error!(%s(users.cant_execute_send_account_activation_mail), remaining_time: remaining_time)
          end

          return true
        end

        def remaining_time_for_new_request
          remaining_seconds = ((@user.activation_sent_at + INTERVAL_TO_SEND_ANOTHER_MAIL ) - Time.zone.now)

          (remaining_seconds/60).round
        end

        def can_request_mail_delivery?
          return true if @user.activation_sent_at.blank?

          Time.zone.now > (@user.activation_sent_at + INTERVAL_TO_SEND_ANOTHER_MAIL)
        end

        def send_account_activation_mail!
          delivery_async_email(UsersMailer, :activate_account, user_id: @user.id)

          @user.update_activation_sent_at(Time.zone.now)
        end

        def record_error_key
          :users
        end
      end
    end
  end
end
