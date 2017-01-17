module API
  module V1
    module Helpers
      module UserNotificationsHelpers
        def paginated_notifications_for_user(user, options = {})
          notifications = paginate(user.notifications)
          notifications.includes(:sender_user, :receiver_user, :notificable)
        end

        def paginated_serialized_notifications(notifications, options = {})
          notifications = notifications.includes(:sender_user, :receiver_user, :notificable)
          options = { serializer: :notification, root: :notifications }.merge(options)
          paginated_serialized_array(notifications, options)
        end
      end
    end
  end
end
