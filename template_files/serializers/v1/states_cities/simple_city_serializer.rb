module Serializers
  module V1
    class SimpleCitySerializer < ActiveModel::Serializer

      root false

      attributes :id, :name

    end
  end
end
