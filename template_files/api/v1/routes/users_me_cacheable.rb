module API
  module V1
    module Routes
      class UsersMeCacheable < API::V1::Base

        helpers API::Helpers::V1::UsersHelpers

        before do
          authenticate_user
        end

        with_cacheable_endpoints :users do
          namespace :me do

            desc 'Get current logged in user data'
            get do
              respond_with_cacheable 'current_user.show', current_user.id do
                serialized_current_user(current_user).as_json
              end
            end
          end
        end
      end
    end
  end
end
