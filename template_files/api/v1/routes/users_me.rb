# encoding: UTF-8

module API
  module V1
    module Routes
      class UsersMe < API::V1::Base

        helpers API::Helpers::V1::UserAuthHelpers

        before do
          authenticate_user
        end

        namespace :users do
          namespace :me do

            desc 'Update user data'
            params do
              requires :user, type: Hash do
                optional :password
                optional :password_confirmation
                optional :phone_area_code
                optional :phone_number
                optional :first_name
                optional :last_name
                optional :name
              end
            end
            put do
              service = execute_service('Users::UpdateService', current_user, current_user, params)
              response_for_update_service(service, :user, serializer: :current_user, root: :data)
            end

            desc 'Suspend user account'
            delete :account do
              service = execute_service('Users::DeleteService', current_user, current_user)
              simple_response_for_service(service)
            end

          end
        end
      end
    end
  end
end
