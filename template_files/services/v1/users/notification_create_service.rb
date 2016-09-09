module Services
  module V1
    module Users
      class NotificationCreateService < BaseCreateService

        record_type ::Notification

        private
        def user_can_create_record?
          true
        end

        def build_record_scope
          @user.notifications
        end

        def notificable
          @options[:notificable]
        end

        def notificable_type
          return @options[:notificable_type] if @options[:notificable_type].present?

          notificable.try(:class).try(:name)
        end

        def notificable_id
          return @options[:notificable_id] if @options[:notificable_id].present?

          notificable.try(:id)
        end

        def notification_type
          @options[:type] || @options[:notification_type]
        end

        def notification_sender_user_id
          @options[:sender_user_id]
        end

        def record_allowed_attributes
          {
            notification_type: notification_type,
            sender_user_id:    notification_sender_user_id,
            notificable_type:  notificable_type,
            notificable_id:    notificable_id,
          }
        end
      end
    end
  end
end
