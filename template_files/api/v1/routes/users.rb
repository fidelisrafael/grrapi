# encoding: UTF-8

module API
  module V1
    module Routes
      class Users < API::V1::Base

        helpers API::Helpers::V1::UsersHelpers

        namespace :users do
          desc 'Create a new user'
          params do
            requires :user, type: Hash do
              requires :name, type: String
              requires :email, type: String, regexp: User::EMAIL_REGEXP
              requires :password, type: String, regexp: User::PASSWORD_REGEXP
              requires :password_confirmation, type: String, regexp: User::PASSWORD_REGEXP
            end

            requires :provider, values: Authorization::PROVIDERS.map(&:to_s)
          end

          post do
            service = execute_service('Users::CreateService', params)

            if service.success?
              response = success_response_for_auth_service(service)
            else
              status service.response_status
              response = error_response_for_service(service)
            end

            response
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
