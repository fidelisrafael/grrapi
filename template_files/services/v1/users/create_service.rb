module Services
  module V1
    module Users
      class CreateService < SimpleServices::BaseCreateService

        record_type ::User

        concern :Users, :Create

        attr_reader :authorization

        delegate :id, :username,
                 :profile_image_url, :oauth_provider, :oauth_provider_uid,
                 to: :user, prefix: :user

        delegate :token, :provider, :expires_at, to: :authorization, prefix: :user_auth, allow_nil: true

        def initialize(options = {})
          super(nil, options)
        end

        def new_user?
          @record.persisted?
        end

        private
        def current_auth_provider
          @options[Application::Config.auth_token_provider_http_param || :auth_provider] || DEFAULT_PROVIDER
        end

        def valid_authentication_provider?
          return false if current_auth_provider.blank?

          Authorization::PROVIDERS.member?(current_auth_provider.to_s)
        end

        def can_create_record?
          unless valid_authentication_provider?
            return unprocessable_entity_error!(%s(users.invalid_authentication_provider))
          end

          return true
        end

        def build_record
          User.new(user_params)
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
        end

        def valid_user?
          return true
        end

        def after_success
          after_success_actions
        end

        def after_success_actions
          create_authorization
          execute_async_actions
        end
      end
    end
  end
end
