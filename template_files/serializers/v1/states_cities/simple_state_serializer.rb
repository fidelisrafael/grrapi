module Serializers
  module V1
    class SimpleStateSerializer < ActiveModel::Serializer

      root false

      attributes :id, :name, :uf, :acronym
    end
  end
end
