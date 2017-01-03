module API
  module V1
    module Helpers
      module StatesHelpers

        extend Grape::API::Helpers

        def states_as_json(states)
          serialized_array(states, serializer: :state)
        end

        def state_as_json(state, meta = {})
          meta_data = { meta: { cities: true }.merge(meta) }
          options = { serializer: :state }.merge(meta_data)

          serialized_object(state, options)
        end

        def state_info_as_json(state_id, options = {})
          state = State.joins(:cities).find_by(id: state_id)

          if state
            return state_as_json(state, options.delete(:meta) || {})
          else
            not_found_error_response(:states)
          end
        end

      end
    end
  end
end
