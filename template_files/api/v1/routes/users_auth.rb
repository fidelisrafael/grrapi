module API
  module V1
    module Routes
      class UsersAuth < API::V1::Base

        helpers API::Helpers::V1::UsersHelpers

        namespace :users do
          namespace :auth do

            desc 'Authenticate an user using email and password'
            params do
              requires :provider, type: String
              requires :email   , type: String
              requires :password, type: String
            end
            post do
              service = authentication_service
              service.execute

              user_auth_response(service)
            end

            desc 'Authenticate using token (must used for app tests)'
            post :token do
              authenticate_user

              user_success_response_for_service(auth_token_validate_service)
            end
          end

          namespace :password_reset do

            desc 'Send a password reset email to user'
            params do
              requires :user, type: Hash do
                requires :identifier
              end
            end

            post do
              identifier = params[:user][:identifier]
              user  = User.find_by('email = :identifier OR username = :identifier', identifier: identifier)

              service = execute_service('Users::PasswordRecoveryService', user, params)

              response_service = {}

              if in_sandbox_environment? && service.success?
                response_service.merge!({
                  reset_password_token: service.user.reset_password_token,
                  alert_message: "'reset_password_token' is only returned in staging and development environment"
                })
              end

              response_for_service(service, response_service)
            end

            desc 'Update user password'
            params do
              requires :password
              requires :password_confirmation
            end

            put '/:token' do
              user = User.find_by(reset_password_token: params[:token])

              service  = execute_service('Users::PasswordUpdateService', user, params)

              response_for_service(service, user_name: service.user_name)
            end
          end

          desc 'Clear user authorizations for token provider'
          delete '/:logout_action', requirements: { logout_action: /(logout|auth)/ }  do
            authenticate_user

            token_service = auth_token_validate_service
            success = token_service.auth_token.try(:destroy)

            simple_response_for_service(token_service)
          end
        end
      end
    end
  end
end
