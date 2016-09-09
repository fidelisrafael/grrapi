module Services
  module V1
    class Auth::TokenValidateService < Auth::CreateService

      def initialize(token, provider, options = {})
        super(nil, nil, nil, options)
        @token = token
        @provider = provider.to_s.downcase
      end

      def execute
        execute_action do
          @auth_token = find_auth_token(@token, @provider)

          if valid_auth_token?(@auth_token)
             success_response
          else
            # in case of token exists in database but is expired
            @auth_token.delete if @auth_token

            not_authorized_error!(%s(auth.invalid_auth_token))
          end
        end
      end

      private
      def find_auth_token(token, provider)
        Authorization.find_by(token: token, provider: provider)
      end

      def valid_auth_token?(auth_token)
        auth_token.present? && auth_token.valid_access?
      end

      def execute_after_success_actions
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
