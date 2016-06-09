module Services
  module V1
    module Auth
      module AuthProviders
        class Base

          attr_reader :access_token, :options, :auth_provider_data, :errors

          def initialize(access_token, options = {})
            @access_token = access_token
            @options = options.to_options!
          end

          def fetch_user
            user_data = memoized_fetch_user_data || {}
            find_user(user_data)
          end

          def find_user(user_data)
            @existent_user = find_existent_user(user_data)
            @existent_user || ::User.new(user_data)
          end

          def find_existent_user(provider_data)
             oauth_provider_uid = provider_data[:oauth_provider_uid]

             ::User.where(
              "(oauth_provider_uid = ? AND oauth_provider = ?) OR email = ?",
              oauth_provider_uid,
              provider_name,
              provider_data[:email]
            ).first
          end

          def existent_user?
            @existent_user.present? && @existent_user.is_a?(User)
          end

          def oauth_provider_uid
            data = memoized_fetch_user_data
            data.is_a?(Hash) ? data[:oauth_provider_uid] : nil
          end

          def fetch_user_data(scope = nil)
            user_data = nil

            begin
              request = provider_request(access_token, scope)
              request_body = request.body
              parsed_body = JSON.parse(request_body)

              if request.is_a?(Net::HTTPOK)
                @auth_provider_data = parsed_body

                user_data = normalized_user_data_from_provider(parsed_body).symbolize_keys
              else
                (@errors ||= []) << (Array.wrap(parsed_body['error'] || parsed_body))
              end
            rescue => e
              (@errors ||= []) << {
                message: e.try(error_message_key) || e.try(:message),
                code: e.try(error_code_key) || e.try(:code),
                status_code: e.try(:http_status) || 500
              }
            end

            user_data
          end

          def provider_request(access_token, uuid = nil)
            uri = URI(provider_request_url(access_token, uuid))

            Net::HTTP.start(uri.host, uri.port,
              :use_ssl => uri.scheme == 'https') do |http|
              request = Net::HTTP::Get.new uri

              response = http.request request # Net::HTTPResponse object
            end
          end

          def error?
            @errors.present?
          end

          def success?
            !error?
          end

          def base_user_data(generate_password = true)
            user_password = generate_password ? SecureRandom.hex : nil

            user_data = {
              password: user_password,
              password_confirmation: user_password,
              oauth_provider_uid: provider_uid,
              oauth_provider: provider_name
            }.deep_symbolize_keys
          end

          def provider_uid
            return nil unless @auth_provider_data

            @auth_provider_data[provider_uid_key.to_s]
          end

          def provider_uid_key
            not_implemented_exception(__method__)
          end

          def provider_request_url(access_token, uuid)
            not_implemented_exception(__method__)
          end

          def memoized_fetch_user_data
            not_implemented_exception(__method__)
          end

          def error_code_key
            :error_code
          end

          def error_message_key
            :error_message
          end


          protected
          def not_implemented_exception(method_name)
            raise NotImplementedError, "#{method_name} must be implemented in subclass"
          end
        end
      end
    end
  end
end
