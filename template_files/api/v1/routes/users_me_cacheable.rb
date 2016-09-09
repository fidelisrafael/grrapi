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

            paginated_endpoint do
              desc 'Get paginated notifications for current user'
              get :notifications do
                response_for_paginated_endpoint 'current_user.paginated_notifications' do
                  notifications = paginated_notifications_for_user(current_user)

                  paginated_serialized_notifications(notifications, serializer: :current_user_notification).as_json
                end
              end
            end # paginated_endpoint

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
