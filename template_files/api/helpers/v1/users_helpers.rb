module API
  module Helpers
    module V1
      module UsersHelpers

        def user_provider_auth_response(service)
          if service.success?
            # success_response_for_auth_service
            response = success_response_for_auth_service(service, new_user: service.new_user?)
          else
            status service.response_status
            response = error_response_for_service(service)
          end

          response
        end

        def success_response_for_auth_service(service, merge_response = {}, options = {})
          status service.response_status
          options = { serializer: %s(Auth::AuthenticationService) }.merge(options)

          serializer_response = serialized_object(service, options).as_json

          {
            success: true,
            status_code: service.response_status,
          }.merge(serializer_response).merge(merge_response)
        end

        def user_auth_response(service)
          if service.success?
            response = success_response_for_auth_service(service)
          else
            status service.response_status

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

        def paginated_notifications_for_user(user, options={})
          notifications = user.notifications
          paginate(notifications).includes(:sender_user, :receiver_user, :notificable)
        end

        def paginated_serialized_notifications(notifications, options = {})
          options = { serializer: :notification, root: :notifications }.merge(options)
          paginated_serialized_array(notifications, options)
        end

        def serialized_user_interests(user, options = {})
          options = { serializer: :user_interest }.merge(options)
          serialized_array(user, options)
        end

      end
    end
  end
end
