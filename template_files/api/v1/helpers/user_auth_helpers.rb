module API
  module V1
    module Helpers
      module UserAuthHelpers
        def user_provider_auth_response(service, options = {})
          if service.success?
            # success_response_for_auth_service
            response = success_response_for_auth_service(service, { new_user: service.new_user? }, options)
          else
            response = response_for_create_service(service, :user)
          end

          response
        end

        def success_response_for_auth_service(service, merge_response = {}, options = {})
          status service.response_status_code
          options = { serializer: 'Auth::AuthenticationService' }.merge(options)

          serializer_response = serialized_object(service, options).as_json

          response = serializer_response.merge(merge_response)

          success_response_for_service(service).merge(response)
        end

        def user_auth_response(service)
          if service.success?
            response = success_response_for_auth_service(service)
          else
            status service.response_status_code

            login_errors = {
              login_blocked: service.login_blocked?,
              login_block_until: service.login_block_until,
              account_activated: service.account_activated?
            }

            response = error_response_for_service(service, login_errors)
          end

          response
        end

        def serialized_user(user, options = {})
          options = { serializer: :user }.merge(options)
          serialized_object(user, options)
        end

        def serialized_current_user(user, options = {})
          serialized_user(user, options.merge(serializer: :current_user))
        end

      end
    end
  end
end
