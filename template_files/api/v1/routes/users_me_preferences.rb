module API
  module V1
    module Routes
      class UsersMePreferences < API::V1::Base

        helpers API::V1::Helpers::UsersHelpers

        before do
          authenticate_user
        end

        namespace :users do
          namespace :me do
            namespace :preferences do

              desc 'Update current user preferences'
              put do
                service = execute_service('Users::PreferencesUpdateService', current_user, current_user, params)

                response_for_update_service(service, :user, serializer: :current_user)
              end
            end
          end
        end

        with_cacheable_endpoints :users do
          namespace :me do
            namespace :preferences do
              desc 'Get current user preferences'
              get do
                respond_with_cacheable 'current_user.preferences', current_user.id do
                  current_user.create_default_preferences

                  current_user.as_json(only: [:id, :preferences], root: nil)
                end
              end
            end # preferences
          end
        end

      end
    end
  end
end
