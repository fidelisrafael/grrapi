module Serializers
  module V1
    class CurrentUserNotificationSerializer < ActiveModel::Serializer

      attributes :id, :read?, :read_at, :created_at

      def attributes
        attrs = super

        attrs.merge(push_attrs)
      end

      protected
      def push_attrs
        push_notification_data_formatter = Application::NotificationDataFormatter.new(
          object.receiver_user,
          object.sender_user,
          object.formatted_body,
          object.notificable,
          object.notification_type,
          push_metadata: object.notificable.try(:push_notification_metadata)
        )

        push_notification_data_formatter.format
      end
    end
  end
end
