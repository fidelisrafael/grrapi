module Services
  module V1
    module Users
      class ActivateAccountService < SimpleServices::BaseUpdateService

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

        private
        # only user can activate your owned account
        def user_can_update?
          @record == @user
        end
      end
    end
  end
end
