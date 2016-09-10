module Services
  module V1
    module Users
      class ActivateAccountService < BaseUpdateService

        record_type ::User

        def update_record
          @user.activate_account!
          @user
        end

        def user_name
          @user.try(:fullname)
        end

        def yet_activated?(token)
          User.account_activated.exists?(activation_token: token)
        end

        def after_success
          notify_user
        end

        def notify_user
          send_push_notification_async(@user, :account_confirmated)
          create_system_notification_async(@user, :account_confirmated, @user, @options)
        end

        private
        # only user can activate your owned account
        def user_can_update_record?
          @record == @user
        end
      end
    end
  end
end
