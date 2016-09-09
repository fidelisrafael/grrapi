module Serializers
  module V1
    class SimpleAddressSerializer < ActiveModel::Serializer

      attributes :id, :city_id, :addressable_id, :addressable_type, :street,
                 :district, :complement, :zipcode
    end
  end
end
