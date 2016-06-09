module Services
  module V1
    module Users
      class ActivateAccountMailerDeliveryService < SimpleServices::BaseActionService

        INTERVAL_TO_SEND_ANOTHER_MAIL = (Application::Config.seconds_to_wait_between_account_activation_mail_resend || 2.minutes).to_i

        action_name :send_account_activation_mail

        attr_reader :user

        def initialize(user, options = {})
          @user = user
          super(options)
        end

        private
        def valid_record?
          valid_user?
        end

        def user_can_execute_action?
          return false unless valid_user?
          return true if @user.activation_sent_at.blank?

          Time.zone.now > (@user.activation_sent_at + INTERVAL_TO_SEND_ANOTHER_MAIL)
        end

        def execute_action
          @user.send_account_activation_mail!
        end

        def record_error_key
          :users
        end

        def success_runned_action?
          @user.activation_sent_at.present?
        end
      end
    end
  end
end
