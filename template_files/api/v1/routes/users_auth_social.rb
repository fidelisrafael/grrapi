module API
  module V1
    module Routes
      class UsersAuthSocial < API::V1::Base

        helpers API::Helpers::V1::UsersHelpers

        namespace :users do
          namespace :auth do

            desc 'Try to authenticate user using social provider (Current only supports Facebook and Google+)'
            params do
              requires :access_token, type: String
            end
            post ':oauth_provider' do
              service = execute_service('Users::ProviderAuthService',
                params.delete(:access_token),
                params.delete(:oauth_provider),
                params
              )

              user_provider_auth_response(service)
            end
          end

        end
      end
    end
  end
end
