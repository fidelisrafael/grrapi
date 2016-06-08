module Services
  module V1
    class Auth::TokenValidateService < Auth::CreateService

      def initialize(token, provider, options={})
        super(nil, nil, options)
        @token = token
        @provider = provider.to_s.downcase
      end

      def execute
        if valid_provider?

          @auth_token = find_auth_token(@token, @provider)

          if valid_auth_token?(@auth_token)
            if @auth_token.valid_access?
              success_response
            else
              @auth_token.delete
            end
          else
            not_authorized_error(%s(auth.invalid_auth_token))
          end
        else
          invalid_provider_response!
        end

        success?
      end

      private
      def find_auth_token(token, provider)
        Authorization.find_by(token: token, provider: provider)
      end

      def valid_auth_token?(auth_token)
        auth_token.present?
      end

      def after_success
        fetch_user_from_auth_token
        update_auth_token_expiration
      end

      def fetch_user_from_auth_token
        @user = @auth_token.try(:user)
      end

      def update_auth_token_expiration
        @auth_token.update_token_expires_at
      end

    end
  end
end
