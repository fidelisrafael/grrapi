module API
  module V1
    module Routes
      class Heartbeat < API::V1::Base

        namespace :heartbeat do
          desc 'Just make sure everything is responding'
          get do
            generic_success_response heartbeats: :beating
          end
        end
      end
    end
  end
end
