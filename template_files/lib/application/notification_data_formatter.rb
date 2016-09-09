module Application
  class NotificationDataFormatter

    attr_reader :receiver_user, :sender_user, :message, :notificable, :notification_type, :options

    def initialize(receiver_user, sender_user, message, notificable, notification_type, options = {})
      @receiver_user = receiver_user
      @sender_user = sender_user
      @message = message
      @notificable = notificable
      @notification_type = notification_type
      @options = options.to_options
    end

    def format
      @formatted_data ||= {
        receiver_user_id: receiver_user.try(:id),
        sender_user_id: sender_user.try(:id),

        receiver_user_image_url: receiver_user.try(:push_notification_image_url),
        sender_user_image_url: sender_user.try(:push_notification_image_url),
        notificable_image_url: notificable.try(:push_notification_image_url),

        notificable_id: notificable.try(:id),
        notificable_type: notificable.try(:class).try(:to_s).try(:underscore),

        message: message,
        notification_type: notification_type,

        metadata: fetch_push_notification_metadata
      }
    end

    protected
    def fetch_push_notification_metadata
      metadata = options.fetch(:push_metadata, nil)

      metadata ||= @notificable.try(:push_notification_metadata)

      metadata || {}
    end
  end
end
