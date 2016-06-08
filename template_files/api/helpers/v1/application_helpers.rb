module API
  module Helpers
    module V1
      module ApplicationHelpers

        def simple_response_for_service(service)
          status service.response_status

          if service.success?
            response = success_response_for_service(service)
          else
            response = error_response_for_service(service)
          end

          response
        end

        def success_response_for_service(service)
          {
            success: true,
            status_code: service.response_status
          }
        end

        def error_response_for_service(service, response_append = {})
          {
            error: true,
            status_code: service.response_status,
            errors: service.errors
          }.merge(response_append)
        end

        def response_for_service(service, response_append = {}, force_merge = false)
          response = simple_response_for_service(service)
          response.merge!(response_append) if force_merge || service.success?

          response
        end

        def response_for_update_service(service, record_type, options = {})
          update_response = {
            updated: service.changed?,
            changed_attributes: service.changed_attributes
          }

          update_response.merge!(serialized_object_from_service(service, record_type, options))

          response_for_service(service, update_response)
        end

        def response_for_delete_service(service, record_type, options = {})
          service_response = serialized_object_from_service(service, record_type, options)
          response_for_service(service, service_response)
        end

        def response_for_create_service(service, record_type, options = {})
          service_response = {}

          if service.success?
            service_response = serialized_object_from_service(service, record_type, options)
          end

          response_for_service(service, service_response)
        end

        def serialized_object_from_service(service, record_type, options = {})
          record = service.send(options.fetch(:service_record_method, record_type))

          serializer    = options.fetch(:serializer, record_type)
          response_root = options.fetch(:root, record_type.to_sym)

          serialized_object_hash = serialized_object(record, serializer: serializer)

          Hash[response_root => serialized_object_hash]
        end

        def not_found_error_response(message_key = nil)
          error_response(404, 'not_found', message_key)
        end

        def forbidden_error_response(message_key = nil)
          error_response(403, 'cant_access', message_key)
        end

        def internal_server_error_response(message_key = nil)
          error_response(500, 'internal_error', message_key)
        end

        def error_response(status_code, type, message_key)
          raise 'Invalid message_key for message error' if message_key.blank?

          response = {
            error: true,
            status_code: status_code,
            errors: [
              I18n.t("simple_services.errors.#{message_key}.#{type}")
            ]
          }

          error!(response, status_code)
        end

        def generic_error_response(status = 400, errors = {})
          status status

          {
            status_code: status,
            error: true,
            errors: errors
          }
        end

        def generic_success_response(status = 200, response = {})
          status status

          response.merge({
            success: true,
            status_code: status
          })
        end

      end
    end
  end
end
