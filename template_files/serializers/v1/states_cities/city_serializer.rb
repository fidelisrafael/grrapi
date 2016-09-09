module Serializers
  module V1
    class CitySerializer < SimpleCitySerializer

      has_one :state, serializer: SimpleStateSerializer

    end
  end
end
