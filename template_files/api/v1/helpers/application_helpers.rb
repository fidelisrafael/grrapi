module API
  module V1
    module Helpers
      module ApplicationHelpers

        def options_for_ordering(params)
          params = params.symbolize_keys

          {
            order_by: params.fetch(:order_by, 'created_at').downcase,
            order: params.fetch(:order, 'DESC').downcase
          }
        end

        def simple_response_for_service(service)
          status service.response_status_code

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
            status: service.response_status,
            status_code: service.response_status_code
          }
        end

        def error_response_for_service(service, response_append = {})

          {
            error: true,
            status: service.response_status,
            status_code: service.response_status_code,
            errors: service_errors(service.errors)
          }.merge(response_append)
        end

        def service_errors(errors)
          errors
        end

        def response_for_service(service, response_append = {}, force_merge = false)
          response = simple_response_for_service(service)

          response.merge!(response_append) if force_merge || service.success?

          if service.fail? && (service.respond_to?(:full_errors_messages?) && service.full_errors_messages?)
            response.merge!(full_errors_messages: service.full_errors_messages)
          end

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
          service_response = serialized_object_from_service(service, record_type, options)

          response_for_service(service, service_response)
        end

        def serialized_object_from_service(service, record_type, options = {})
          record = service.send(options.fetch(:service_record_method, record_type))

          serializer    = options.fetch(:serializer, record_type)
          response_root = options.fetch(:root, record_type.to_sym)

          serialized_object_hash = serialized_object(record, serializer: serializer)

          return serialized_object_hash.serializable_hash unless response_root

          Hash[response_root => serialized_object_hash]
        end

        def not_found_error_response(message_key = nil)
          error_response_for_code(404, 'not_found', message_key, :grouped_by_type)
        end

        def bad_request_error_response(message_key = nil)
          error_response_for_code(400, 'bad_request', message_key)
        end

        def unprocessable_entity_error_response(message_key = nil)
          error_response_for_code(422, 'unprocessable_entity', message_key)
        end

        def forbidden_error_response(message_key = nil)
          error_response_for_code(403, 'cant_access', message_key)
        end

        def internal_server_error_response(message_key = nil)
          error_response_for_code(500, 'internal_error', message_key)
        end

        def error_response_for_code(status_code, type, message_key, i18n_type = :by_error_type)
          raise 'Invalid message_key for message error' if message_key.blank?

          errors = [
            i18n_type == :by_error_type ?
               I18n.t("errors.#{type}.#{message_key}") :
               I18n.t("errors.#{message_key}.#{type}")
          ]

          generic_error_response(status_code, errors)
        end

        def generic_error_response(status = 400, errors = {})
          status status

          response = {
            status_code: status,
            error: true,
            errors: errors
          }

          # TODO: FIX ME
          response # error!(response) (this invalidate cache :( )
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
