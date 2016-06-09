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
        def can_create_record?
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
            return @authorization ||= @record.authorizations.create(provider: @options[:provider] || DEFAULT_PROVIDER)
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
