module API
  module V1
    module Helpers
      module CitiesHelpers

        extend Grape::API::Helpers

        def serialized_city(city, options = {})
          options = { serializer: :city }.merge(options)
          serialized_object(city, options)
        end

      end
    end
  end
end
