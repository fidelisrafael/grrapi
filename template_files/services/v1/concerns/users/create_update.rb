module Services::V1::Concerns
  module Users
    module CreateUpdate

      extend ActiveSupport::Concern

      WHITELIST_ATTRIBUTES = [
        :name,
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :tof_accepted
      ]

      ADDRESS_WHITELIST_ATTRIBUTES = [
        :city_id,
        :street,
        :number,
        :district,
        :complement,
        :zipcode
      ]

      DEFAULT_PROVIDER = :web

      included do
        def record_attributes_whitelist
          WHITELIST_ATTRIBUTES
        end

        def set_address_for_user(save = false)
          record = (@record || @temp_record)
          record.address_attributes = address_attributes_for_user
          record.save if save

          record
        end

        def current_address_city
          @current_city ||= City.find_by(id: address_city_id)
        end

        def valid_city?
          return true unless validate_city?

          return false if address_city_id.blank? || !current_address_city

          address_data = current_zipcode_address_data

          current_state = ((address_data[:data] && address_data[:data][:state]) || address_data[:state]).try(:parameterize)

          [
            current_address_city.state_name,
            current_address_city.state_acronym
          ].map(&:parameterize).member?(current_state)
        end

        def current_auth_provider
          @options[(Application::Config.auth_token_provider_http_param || :auth_provider).to_sym] || DEFAULT_PROVIDER
        end


        def validate_city?
          return option_enabled?(:validate_address_city) if option_exists?(:validate_address_city)

          Application::Config.enabled?(:validate_user_address_on_signup)
        end

        def valid_authentication_provider?
          return false if current_auth_provider.blank?

          Authorization::PROVIDERS.member?(current_auth_provider.to_s)
        end

        def perform_validations
          unless valid_authentication_provider?
            return unprocessable_entity_error!(%s(users.invalid_authentication_provider))
          end

          unless valid_city?
            if address_city_id.present?
              address_data = current_zipcode_address_data

              opts = {
                city_name: current_address_city.try(:name) || 'Indefinida',
                state_name: address_data[:state]
              }

              return invalid_city_id_error!(opts)
            else
              return not_found_city_error!
            end
          end

          return true
        end

        def superuser_creation?
          [:staff, :admin].member?(attributes_hash[:profile_type].to_sym)
        end

        def backstage_user_creation?
          superuser_creation?
        end

        def obtain_password_confirmation
          attributes_hash.fetch(:password_confirmation, true)
        end

        def record_attributes_hash
          attributes = attributes_hash

          attributes[:password_confirmation] ||= obtain_password_confirmation

          # avoid admin creation via endpoints
          if !can_create_staff_user? && (backstage_user_creation?)
            attributes[:profile_type] = User::VALID_PROFILES_TYPES[:common_user]
          end

          attributes[:address_attributes] = address_attributes_for_user unless superuser_creation?

          attributes
        end

        def address_params
          @address_params ||= filter_hash(address_attributes_hash, ADDRESS_WHITELIST_ATTRIBUTES)
        end

        def address_attributes_for_user
          address_params.merge(skip_addressable_validation: true)
        end

        def attributes_hash
          @options.fetch(:user, {}).to_h.symbolize_keys
        end

        def address_attributes_hash
          attributes_hash.fetch(:address, {}).to_h.symbolize_keys
        end

        def non_change_trackable_attributes
          [:password_confirmation]
        end

        def updating_profile_image?
          attributes_hash && attributes_hash[:profile_image].present?
        end

        def can_create_staff_user?
          @options[:allow_create_staff_user].present? && valid_key_for_request?
        end

        def valid_key_for_request?
          unless master_api_key.present?
            return forbidden_error!(%s(invalid_master_api_key))
          end

          return (@options[:api_key] == master_api_key)
        end

        def fetch_address_data(zipcode)
          @addreses_data ||= {}

          zipcode = Address.normalize_zipcode(zipcode)

          return @addreses_data[zipcode] if @addreses_data.key?(zipcode)

          @addreses_data[zipcode] = address_data_from_cache(zipcode) || {}
        end

        def current_zipcode_address_data
          fetch_address_data(address_attributes_hash[:zipcode])
        end

        def address_data_from_cache(zipcode)
          Application::Cache.client.fetch('zipcode.show', replace_data: [zipcode]) do
            address_service = Services::V1::Addresses::ZipcodeFetchService.new(zipcode)
            address_service.execute

            return nil unless address_service.success?

            address_service.address_data
          end
        end

        def master_api_key
          Application::Config.master_api_key
        end

        def address_city_id
          address_attributes_hash[:city_id]
        end

        def invalid_city_id_error!(options)
          unprocessable_entity_error!(%s(cities.must_belongs_to_zipcode), options)
        end

        def not_found_city_error!
          unprocessable_entity_error!(%s(cities.not_found))
        end
      end
    end
  end
end
