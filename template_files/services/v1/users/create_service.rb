module Services
  module V1
    module Users
      class CreateService < BaseCreateService

        record_type ::User

        concern :Users, :CreateUpdate

        attr_reader :authorization

        delegate :id, :username,
                 :profile_image_url, :oauth_provider, :oauth_provider_uid,
                 to: :user, prefix: :user

        delegate :token, :provider, :expires_at, to: :authorization, prefix: :user_auth, allow_nil: true

        def initialize(options = {})
          super(nil, options)
        end

        def new_user?
          return true
        end

        private
        def after_build_record
          set_address_for_user if create_address?
        end

        def create_origin?
          new_user?
        end

        def user_can_create_record?
          perform_validations
        end

        def valid_user?
          return true
        end

        def after_success
          after_success_actions
        end

        def after_success_actions
          activate_account
          create_authorization
          execute_async_actions
        end

        def activate_account
          # if application config only allow activated users to login
          return nil if Application::Config.enabled?(:force_account_activation_to_enable_login)

          # if activation to login is disabled, confirm user account to avoid
          # problems when turning config enabled in future (old users will not be able to login)
          @record.activate_account!
        end

        def create_address?
          return false if @options[:create_address] == false

          return false if superuser_creation?

          (@temp_record || @record).address.blank?
        end

        def async?
          return Application::Config.enabled?(:update_user_after_signup_async) || @options[:async].eql?(true)
        end

        def create_authorization
          if @record.account_activated?
            return @authorization ||= @record.authorizations.create(provider: current_auth_provider)
          end

          @authorization = nil
        end

        def execute_async_actions
          # try to find `device` key in @options[:device] && @options[:user][:device]
          update_service_options = @options
                                    .slice(:origin, :device)
                                    .merge(@options.fetch(:user, {}).slice(:device))

          update_service_options[:notify_user] = new_user?
          update_service_options[:device] && update_service_options[:device][:origin] = origin_params(@options[:origin])

          if async?
            Workers::V1::UserSignupUpdateWorker.perform_async(@record.id, update_service_options)
          else
            Workers::V1::UserSignupUpdateWorker.new.perform(@record.id, update_service_options)
          end
        end
      end
    end
  end
end
