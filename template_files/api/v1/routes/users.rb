# encoding: UTF-8

module API
  module V1
    module Routes
      class Users < API::V1::Base

        helpers API::Helpers::V1::UserAuthHelpers

        namespace :users do
          desc 'Create a new user'
          params do
            requires :user, type: Hash do
              requires :name, type: String
              requires :email, type: String, regexp: User::EMAIL_REGEXP
              requires :password, type: String, regexp: User::PASSWORD_REGEXP
              requires :password_confirmation, type: String, regexp: User::PASSWORD_REGEXP

              optional :address, type: Hash do
                requires :street, type: String
                requires :zipcode, type: String
                requires :number, type: String
                requires :city_id, type: Integer
              end

              optional :device, type: Hash do
                requires :installation_id, type: String
                requires :token, type: String
                requires :platform, type: String, values: ::UserDevice::VALID_PLATFORMS.values
              end
            end

            requires :auth_provider, values: Authorization::PROVIDERS.map(&:to_s)
          end

          post do
            service = execute_service('Users::CreateService', params)
            user_provider_auth_response(service, serializer: 'Auth::UserCreateService')
          end

          desc 'Check if user with given mail exists'
          params do
            requires :email, type: String, regexp: User::EMAIL_REGEXP
          end
          get :check_email do
            u = User.find_by(email: params[:email].squish)

            response_status = u.present? ? 200 : 404

            status response_status

            {
              status_code: response_status,
              user_exists: response_status == 200
            }

          end
        end
      end
    end
  end
end
