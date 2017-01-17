module API
  module V1
    module Routes
      class UsersMeNotifications < API::V1::Base

        helpers API::V1::Helpers::UsersHelpers

        before do
          authenticate_user
        end

        namespace :users do
          namespace :me do
            desc 'Flag notification as read'
            put '/notifications/:id' do
              notification = current_user.notifications.unread.find_by(id: params[:id])

              if notification.try(:mark_as_read)
                status 204
              else
                status 403
              end
            end
          end
        end

        with_cacheable_endpoints :users do
          namespace :me do
            paginated_endpoint do
              desc 'Get paginated notifications for current user'
              get :notifications do
                response_for_paginated_endpoint 'current_user.paginated_notifications' do
                  options = { serializer: :current_user_notification }
                  paginated_serialized_notifications(current_user.notifications, options).as_json
                end
              end
            end # paginated_endpoint
          end
        end
      end
    end
  end
end
