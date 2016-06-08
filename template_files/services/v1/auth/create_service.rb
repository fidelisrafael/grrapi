module Services
  module V1
    class Auth::CreateService < BaseService

      attr_reader :email, :password, :user, :auth_token

      MAX_SESSIONS_PER_PROVIDER = (Application::Config.max_simultaneous_authorizations_per_provider).to_i

      # create convenience public methods such: user_id, user_oauth_provider
      delegate :id, :username, :oauth_provider, :oauth_provider_uid, to: :user, prefix: :user

      # create convenience public methods such: user_auth_provider, user_auth_token
      delegate :provider, :expires_at, :token, to: :auth_token, prefix: :user_auth

      def initialize(email, password, options = {})
        super(options, 401)
        @email = email
        @password = password
      end

      def execute
        if can_execute_action?

          @user = User.authenticate(@email, @password)

          if valid_user?
            unless account_activated?
              return forbidden_error!(%s(auth.user_account_not_activated))
            end

            unless check_user_login_block(@user, false)
              success_created_response
            end
          else
            unless check_user_login_block(user_from_email)
              not_authorized_error(%s(auth.invalid_user_credentials))
            end
          end
        end

        success?
      end

      def login_blocked?
        valid_object?(@blocked_user, ::User)
      end

      def login_block_until
        login_blocked? && @blocked_user.blocked_until
      end

      def account_activated?
        @user.try(:account_activated?)
      end

      def new_user?
        @user.first_login_on_provider?(current_auth_provider)
      end

      private
      def check_user_login_block(user, update_counter = true)
        return false unless user

        user.update_login_attempts_counter if update_counter

        if user.blocked?
          @blocked_user = user
          blocked_until = user.blocked_until.to_formatted_s(:short)
          not_authorized_error(%s(auth.user_login_blocked), blocked_until: blocked_until)
        end

        return user.blocked?
      end

      def user_from_email
        @user_from_email ||= User.find_by(email: @email)
      end

      def can_execute_action?
        unless valid_provider?
          return invalid_provider_response!
        end

        return true
      end

      def after_success
        execute_after_success_actions
      end

      def execute_after_success_actions
        unblock_user!
        clear_provider_authorizations
        create_authorization_for_provider
      end

      def unblock_user!
        @user.unblock!
      end

      def valid_providers
        Authorization::PROVIDERS.map(&:to_sym)
      end

      def valid_provider?
        return valid_providers.member?(current_auth_provider.to_sym)
      end

      def current_auth_provider
        @provider ||= @options[:provider]

        @provider.to_s.downcase
      end

      def create_authorization_for_provider
        if @auth_token = @user.authorizations.create(provider: current_auth_provider)
          @user.update_login_count_from_provider!(current_auth_provider)
        end

        @auth_token
      end

      def clear_provider_authorizations
        scope = @user.authorizations.where(provider: current_auth_provider)
        scope.delete_all if MAX_SESSIONS_PER_PROVIDER > 0 && (scope.count > MAX_SESSIONS_PER_PROVIDER)
      end

      def invalid_provider_response!
        bad_request_error!(%s(auth.invalid_auth_provider), valid_providers: valid_providers.to_sentence)
      end
    end
  end
end
