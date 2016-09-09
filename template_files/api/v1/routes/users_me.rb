# encoding: UTF-8

module API
  module V1
    module Routes
      class UsersMe < API::V1::Base

        helpers API::Helpers::V1::UsersHelpers

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

            desc 'Flag notification as read'
            put '/notifications/:id' do
              notification = current_user.notifications.unread.find_by(id: params[:id])

              if notification.try(:mark_as_read)
                status 204
              else
                status 403
              end
            end

            namespace :preferences do

              desc 'Update current user preferences'
              put do
                service = execute_service('Users::PreferencesUpdateService', current_user, current_user, params)

                response_for_update_service(service, :user, serializer: :current_user)
              end
            end

            desc 'Update user profile_image'
            params do
              requires :user, type: Hash do
                requires :profile_image, type: File
              end
            end
            put :profile_image do
              service = execute_service('Users::ProfileImageUpdateService', current_user, current_user, params)

              response_for_service(service, data: { profile_image_urls: service.images_url } )
            end

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
