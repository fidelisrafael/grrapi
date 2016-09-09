module Services
  module V1
    class Addresses::ZipcodeFetchService < BaseActionService

      action_name :fetch_zipcode

      attr_reader :zipcode, :address_data

      POSTMON_ENDPOINT = 'http://api.postmon.com.br/v1/cep/%s'
      FETCH_READ_TIMEOUT = (Application::Config.zipcode_fetch_remote_api_timeout_seconds || 60).to_i

      def initialize(zipcode, options = {})
        super(options)
        @zipcode = normalize_zipcode(zipcode)
      end

      def response
        @address_data || {}
      end

      private
      def execute_service_action
        @address_data = address_hash_from_zipcode(@zipcode)
      end

      def user_can_execute_action?
        unless valid_zipcode?
          return unprocessable_entity_error!(%s(addresses.invalid_zipcode))
        end

        return true
      end

      def record_error_key
        :addresses
      end

      def valid_zipcode?
        @zipcode.present? && @zipcode.match(/\d{6,8}/).present?
      end

      # merge this hash with address params
      def address_hash_from_zipcode(zipcode)
        address_attributes = zipcode_data(zipcode)
        address_hash = {}

        if address_attributes.any?
          city = city_from_address_attributes(address_attributes)

          address_hash = {
            street: address_attributes[:logradouro],
            district: address_attributes[:bairro],
            city: city.as_json,
            state: address_attributes[:estado],
            zipcode: address_attributes[:cep],
            raw_data: address_attributes
          }

          address_hash.keep_if { |_, v| v.present? }
        end

        address_hash
      end

      def zipcode_data(zipcode)
        zipcode = normalize_zipcode(zipcode)
        data = {}
        cep_endpoint = POSTMON_ENDPOINT % zipcode

        begin
          zipcode_data = open(cep_endpoint, read_timeout: FETCH_READ_TIMEOUT)
          data = JSON.parse(zipcode_data.read).symbolize_keys rescue nil
        rescue Net::ReadTimeout => e
          internal_server_error!(%s(addresses.zipcode_read_timeout))
        rescue => e
          message = e.message

          message.match(/^404/) ? not_found_error!('addresses.zipcode_not_found') :
                                  internal_server_error!(message, translate: false)
        end

        data
      end

      def city_from_address_attributes(address_attributes = {})
        city_name = address_attributes[:cidade]
        city_uf = address_attributes[:estado]

        query = {
          city_name: city_name.downcase,
          city_uf: city_uf
        }

        ::City.joins(:state)
              .where("lower(cities.name) = :city_name AND states.acronym = :city_uf", query).last
      end

      def normalize_zipcode(zipcode)
        Address.normalize_zipcode(zipcode)
      end

    end
  end
end
