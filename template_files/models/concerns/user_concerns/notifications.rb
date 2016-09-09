module UserConcerns
  module Notifications

    extend ActiveSupport::Concern

    PUSH_NOTIFICATION_CHANNELS = {
      user_device:      'user_device_%s',
      device_plataform: 'device_platform_%s',
      profile_type:     'users_profile_type_%s',
      user_id:          'user_id_%s'
    }

    included do
      # Notifications
      has_many :devices, class_name: 'UserDevice', dependent: :destroy

      has_many :notifications, foreign_key: :receiver_user_id

      has_many :originated_notifications, foreign_key: :sender_user_id, class_name: 'Notification' #, dependent: :destroy

      has_many :push_notification_historics, foreign_key: :receiver_user_id

      def notify(notification_data, method = :create)
        self.notifications.send(method, notification_data)
      end

      def notifications_status
        @notifications_status ||= {
          read: read_notifications_count,
          unread: unread_notifications_count
        }
      end

      def unread_notifications_count
        self.notifications.unread.count
      end

      def read_notifications_count
        self.notifications.read.count
      end

      def channels_for_notification(device = nil)
        channels = [
          PUSH_NOTIFICATION_CHANNELS[:profile_type] % self.profile_type.to_s.underscore,
          PUSH_NOTIFICATION_CHANNELS[:user_id] % self.id,
        ]

        channels.concat(channels_for_device(device)) if device.present?

        channels.flatten.uniq
      end

      def channels_for_device(device)
        [
          channel_for_specific_device(device),
          PUSH_NOTIFICATION_CHANNELS[:device_plataform] % device.platform
        ]
      end

      def channel_for_specific_device(device)
        PUSH_NOTIFICATION_CHANNELS[:user_device] % device.identifier
      end

    end
  end
end
