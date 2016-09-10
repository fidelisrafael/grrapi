module Services
  module V1
    class Auth::CreateService < BaseActionService

      action_name :auth_create

      attr_reader :auth_attribute, :auth_attribute_value, :password, :user, :auth_token

      MAX_SESSIONS_PER_PROVIDER = (Application::Config.max_simultaneous_authorizations_per_provider).to_i

      DEFAULT_AUTH_ATTRIBUTE = :email

      # create convenience public methods such: user_id, user_oauth_provider
      delegate :id, :username, :oauth_provider, :oauth_provider_uid, to: :user, prefix: :user

      # create convenience public methods such: user_auth_provider, user_auth_token
      delegate :provider, :expires_at, :token, to: :auth_token, prefix: :user_auth

      def initialize(auth_attribute, auth_attribute_value, password, options = {})
        super(options, 401)
        @auth_attribute = (auth_attribute || options[:authenticate_by] || DEFAULT_AUTH_ATTRIBUTE).to_sym
        @auth_attribute_value = normalize_auth_attribute_value(auth_attribute_value)
        @password = password
      end

      def login_blocked?
        valid_object?(@blocked_user, ::User)
      end

      def login_block_until
        login_blocked? && @blocked_user.blocked_until
      end

      def account_activated?
        return true if Application::Config.disabled?(:force_account_activation_to_enable_login)

        return @user.try(:account_activated?)
      end

      def new_user?
        @user.first_login_on_provider?(current_auth_provider)
      end

      private
      def user_can_execute_action?
        return invalid_provider_response! unless valid_provider?

        return true
      end

      def execute_service_action
        @user = authenticate_user_by_attribute

        valid_user? ? check_valid_user_can_login : check_blocked_login
      end

      def authenticate_user_by_attribute
        validate_allowed_auth_attribute!

        User.send("authenticate_by_#{@auth_attribute}", @auth_attribute_value, @password)
      end

      def check_blocked_login
        unless check_user_login_block(user_from_auth_attribute)
          not_authorized_error(%s(auth.invalid_user_credentials))
        end
      end

      def check_valid_user_can_login
        unless account_activated?
          return forbidden_error!(%s(auth.user_account_not_activated))
        end

        if check_user_login_block(@user, false)
          return forbidden_error!(%s(auth.user_login_blocked))
        end
      end


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

      def user_from_auth_attribute
        validate_allowed_auth_attribute!

        @user_from_auth_attribute ||= User.find_by(@auth_attribute => @auth_attribute_value)
      end

      def valid_providers
        Authorization::PROVIDERS.map(&:to_sym)
      end

      def valid_provider?
        return valid_providers.member?(current_auth_provider.to_sym)
      end

      def current_auth_provider
        @provider ||= @options[:auth_provider] || @options[:provider]

        @provider.to_s.downcase
      end

      def invalid_provider_response!
        bad_request_error!(%s(auth.invalid_auth_provider), valid_providers: valid_providers.to_sentence)
      end

      def update_login_count_from_provider(auth_provider)
        ::Workers::V1::UpdateLoginStatusHistoricWorker.perform_async(@user.id, auth_provider)
      end

      def normalize_auth_attribute_value(auth_attribute_value)
        return nil if auth_attribute_value.blank?

        return auth_attribute_value.to_s
      end

      def allowed_auth_attributes
        User::ALLOWED_AUTH_ATTRIBUTES
      end

      def can_create_authorization?
        return false unless @user

        account_activated?
      end

      def validate_allowed_auth_attribute!
        unless allowed_auth_attributes.member?(@auth_attribute.to_sym)
          raise "Not allowed authentication attribute, valids are: #{allowed_auth_attributes.join(', ')}"
        end

        return true
      end

      def record_error_key
        :auth
      end

      def after_success
        execute_after_success_actions
      end

      def execute_after_success_actions
        unblock_user!
        clear_provider_authorizations
        create_authorization_for_provider
        register_new_devices_for_push
        create_origin_async(@auth_token, @options)
      end

      def register_new_devices_for_push
        device_data = @options.slice(:device) || (@options[:user] && @options[:user]).slice(:device)
        device_data[:origin] = @options[:origin]

        return nil unless device_data.present?

        if Application::Config.enabled?(:save_user_device_async)
          ::Workers::V1::ParseDeviceCreateWorker.perform_async(@user.id, device_data, true)
        else
          ::Workers::V1::ParseDeviceCreateWorker.new.perform(@user.id, device_data, true)
        end
      end

      def unblock_user!
        @user.unblock!
      end

      def create_authorization_for_provider
        return nil unless can_create_authorization?

        return @auth_token if @auth_token

        @auth_token = @user.authorizations.create(provider: current_auth_provider)

        update_login_count_from_provider(current_auth_provider) if @auth_token.valid?

        @auth_token
      end

      def clear_provider_authorizations
        scope = @user.authorizations.where(provider: current_auth_provider)
        scope.delete_all if MAX_SESSIONS_PER_PROVIDER > 0 && (scope.count > MAX_SESSIONS_PER_PROVIDER)
      end

    end
  end
end
