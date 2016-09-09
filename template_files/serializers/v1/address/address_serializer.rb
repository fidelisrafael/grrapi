require_relative '../states_cities/city_serializer'

module Serializers
  module V1
    class AddressSerializer < SimpleAddressSerializer

      has_one :city, serializer: CitySerializer

    end
  end
end
