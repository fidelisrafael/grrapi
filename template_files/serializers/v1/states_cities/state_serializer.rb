module Serializers
  module V1
    class StateSerializer < SimpleStateSerializer

      attributes :cities_count

      def cities_count
        cities.size
      end

      def attributes
        hash = {}
        if @meta && @meta[:cities]
          hash = { cities: cities.as_json(only: [:id, :name]) }
        end

        return hash if @meta && @meta[:only_cities]

        super.merge(hash)
      end

      private
      def cities
        @cities ||= object.cities.sort_by(&:name)
      end

    end
  end
end
