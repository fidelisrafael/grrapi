module API
  module V1
    module Routes
      class States < API::V1::Base

        helpers Helpers::V1::StatesHelpers

        with_cacheable_endpoints :states do

          desc 'Return a list of all states'
          get do
            respond_with_cacheable('states.all') do
              states_as_json(State.includes(:cities).all).as_json
            end
          end

          desc 'Return info and cities list of given state'
          route_param :id do
            get do
              respond_with_cacheable('states.show', params[:id]) do
                state_info_as_json(params[:id]).as_json
              end
            end

            desc 'Return only cities of given state'
            get :cities do
              respond_with_cacheable('states.cities', params[:id]) do
                state_info_as_json(params[:id], meta: { only_cities: true }).as_json
              end
            end
          end
        end
      end
    end
  end
end
