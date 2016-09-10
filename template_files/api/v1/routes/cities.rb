module API
  module V1
    module Routes
      class Cities < API::V1::Base

        helpers Helpers::V1::CitiesHelpers

        with_cacheable_endpoints :city do

          desc 'Return data of given city'

          route_param :id do
            get do
              respond_with_cacheable('cities.show', params[:id]) do
                city = City.includes(:state).find_by(id: params[:id])
                if city
                  options = {
                    serializer: :simple_city
                  }
                  serialized_object(city, options).as_json
                else
                  not_found_error_response(:cities)
                end
              end
            end
          end
        end
      end
    end
  end
end
