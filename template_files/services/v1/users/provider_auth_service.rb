module Services
  module V1
    module Users
      class ProviderAuthService < Users::CreateService

        VALID_PROVIDERS = [
          :facebook,
          :google_plus
        ]

        attr_reader :access_token, :provider

        def initialize(access_token, provider, options = {})
          @access_token = access_token
          @provider     = provider
          super(options)
        end

        def new_user?
          return false if @auth_class.nil?
          !@auth_class.existent_user?
        end

        private
        def create_user_from_provider
          @user = @auth_class.fetch_user

          if errors = @auth_class.errors
            error = (errors.flatten.first || { 'message' => 'Unknown error' }).symbolize_keys
            unprocessable_entity_error(error[:message], no_i18n: true)
          else
            @user.oauth_provider_uid = @auth_class.oauth_provider_uid
            @user.oauth_provider = @auth_class.provider_name
          end

          @user
        end

        def build_record
          begin
            @auth_class = init_oauth_provider_class
            create_user_from_provider
          rescue Exception => e
            forbidden_error!(e.message)
          end
        end

        def init_oauth_provider_class
          "Services::V1::Auth::AuthProviders::#{provider.to_s.camelize}".constantize.send(:new, @access_token)
        end

        def can_create_record?
          return false if @access_token.blank?

          unless valid_service_oauth_provider?
            return unprocessable_entity_error!(%s(users.invalid_service_oauth_provider))
          end

          super
        end

        def valid_user?
          return true
        end

        def valid_service_oauth_provider?
          return false if @provider.blank?

          VALID_PROVIDERS.member?(@provider.to_sym)
        end

        def after_execute_success_response
          new_user? ? success_created_response : success_response
        end

        def after_success_actions
          # no need to confirm user account when user signup through social logins(facebook, g+)
          activate_user_account
          fetch_avatar_from_provider unless Rails.env.development?
          create_authorization
          execute_async_actions
        end

        def activate_user_account
          @user.activate_account!
        end

        def fetch_avatar_from_provider
          return false if @user.has_uploaded_image?
          return false unless @auth_class.respond_to?(:provider_remote_avatar_url, true)

          @user.remote_profile_image_url = @auth_class.provider_remote_avatar_url(@user.oauth_provider_uid)
          @user.save
        end

        def create_error_response(record)
          return {} unless @errors.blank?
          super(record)
        end
      end
    end
  end
end
