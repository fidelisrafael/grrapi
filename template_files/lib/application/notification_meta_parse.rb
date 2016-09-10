module Application
  class NotificationMetaParse

    attr_reader :receiver_user, :sender_user, :notificable, :options

    def initialize(receiver_user, sender_user, notificable, options = {})
      @receiver_user = receiver_user
      @sender_user  = sender_user
      @notificable = notificable
      @options = options.to_options
    end

    def parse
      notification_meta = {
        receiver_user_name: receiver_user.try(:name),
        sender_user_name: sender_user.try(:name)
      }.merge(options[:notification_data] || {})

      notification_meta
    end
  end
end
