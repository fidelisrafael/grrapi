# encoding: UTF-8

module API
  module V1
    module Routes
      class UsersMeUpdateImage < API::V1::Base

        helpers API::V1::Helpers::UsersHelpers

        before do
          authenticate_user
        end

        namespace :users do
          namespace :me do
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
          end
        end
      end
    end
  end
end
