module API
  module Helpers
    module AuthHelpers

      AUTH_TOKEN_HTTP_HEADER = Application::Config.auth_token_http_header
      AUTH_TOKEN_HTTP_PARAM  = Application::Config.auth_token_http_param

      AUTH_TOKEN_PROVIDER_HTTP_PARAM  = Application::Config.auth_token_provider_http_param
      AUTH_TOKEN_PROVIDER_HTTP_HEADER  = Application::Config.auth_token_provider_http_header

      def authentication_token
        params[AUTH_TOKEN_HTTP_PARAM] || headers[AUTH_TOKEN_HTTP_HEADER]
      end

      def authentication_provider
        params[AUTH_TOKEN_PROVIDER_HTTP_PARAM] || headers[AUTH_TOKEN_PROVIDER_HTTP_HEADER]
      end

      def authenticate_user
        unless current_user
          response = token_authentication_error_response
          error!(response, response[:status_code])
        end
      end

      def auth_attribute
        return :email
      end

      def auth_attribute_value
        params.fetch(auth_attribute, nil)
      end

      def auth_password_param
        params.delete(:password)
      end

      def auth_params
        params
      end

      def token_authentication_error_response
        error_response_for_service(auth_token_validate_service)
      end

      def current_user
        return @current_user if @current_user

        service = auth_token_validate_service
        service.execute

        @current_user = service.try(:user)
      end

      def authentication_service
        @authentication_service ||= initialize_service(authentication_create_service_name,
          auth_attribute,
          auth_attribute_value,    # from params
          auth_password_param, # from params
          auth_params          # options
        )
      end

      def auth_token_validate_service
        @auth_token_validate_service ||= initialize_service(authentication_token_validate_service_name,
          authentication_token,   # from request headers or params
          authentication_provider # from request heades or params
        )
      end
    end
  end
end
