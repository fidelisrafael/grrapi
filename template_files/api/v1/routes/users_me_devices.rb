module API
  module V1
    module Routes
      class UsersMeDevices < API::V1::Base

        helpers API::V1::Helpers::UsersHelpers

        before do
          authenticate_user
        end

        namespace :users do
          namespace :me do
            desc 'Create a new device in Parse'
            params do
              requires :device, type: Hash do
                requires :token, type: String
                requires :platform, type: String, values: ::UserDevice::VALID_PLATFORMS.values
              end
            end
            post :devices do
              service = execute_service('Parse::DeviceCreateService', current_user, params.to_h)

              simple_response_for_service(service)
            end
          end
        end
      end
    end
  end
end
