module Services
  module ServiceExtensions

    def default_options
      { delivery_email: true, send_push_notification: true, create_system_notification: true }
    end

    def delivery_email?
      option_enabled?(:delivery_email)
    end

    def delivery_sync_email(mailer, mailer_method, *args)
      delivery_email(mailer, mailer_method, *args)
    end

    def delivery_async_email(mailer, mailer_method, args)
      delivery_email(mailer, mailer_method, args)
    end

    def delivery_email(mailer, mailer_method, args)
      return false unless delivery_email?

      options = { mailer: mailer.to_s, mailer_method: mailer_method.to_s, args: args }

      if delivery_mail_async?
        ::Workers::V1::MailDeliveryWorker.perform_async(options)
      else
        ::Workers::V1::MailDeliveryWorker.new.perform(options)
      end
    end

    def send_push_notification_async(user, type, notificable = nil, options = {})
      options.merge! async: Application::Config.enabled?(:send_push_notifications_async)

      send_push_notification(user, type, notificable, options)
    end

    def send_push_notification_sync(user, type, notificable = nil, options = {})
      options.merge! async: false

      send_push_notification(user, type, notificable, options)
    end

    def send_push_notification(user, type, notificable = nil, options = {})
      return false unless send_push_notification?
      return false unless user_preference_on?(user, notification_preference_key(type))

      push_data = push_notification_data(user, notificable, type, options)

      async = options[:async].eql?(true)

      if async
        Workers::V1::PushNotificationDeliveryWorker.perform_async(user.id, push_data)
      else
        Workers::V1::PushNotificationDeliveryWorker.new.perform(user.id, push_data)
      end
    end

    def push_notification_data(user, notificable, notification_type, options = {})
      data  = Application::NotificationMetaParse.new(user, options[:origin_user], notificable, options).parse
      body  = I18n.t(notification_type, scope: 'notifications')

      alert = (body % data) rescue body
      sanitized_alert = Application::Helpers.strip_tags(alert)

      {
        alert: sanitized_alert,
        data: data_for_push(user, options[:origin_user], sanitized_alert, notificable, notification_type, options)
      }
    end

    def data_for_push(receiver_user, sender_user, message, notificable, notification_type, options = {})
      formatter = Application::NotificationDataFormatter.new(receiver_user,
                                                            sender_user,
                                                            message,
                                                            notificable,
                                                            notification_type,
                                                            options)

      formatter.format
    end

    def notification_preference_key(notification_type)
      "notify_#{notification_type.to_s.downcase.underscore}".to_sym
    end

    def send_push_notification?
      option_enabled?(:send_push_notification)
    end

    def delivery_mail_async?
      Application::Config.enabled?(:send_email_async)
    end

    def create_system_notification?
      option_enabled?(:create_system_notification)
    end

    def create_system_notification(user, type, notificable = nil, options = {})
      return false unless create_system_notification?

      options = options.merge(type: type.to_sym, notificable: notificable)

      service = ::Services::V1::Users::NotificationCreateService.new(user, options)
      service.execute
    end

    def create_system_notification_async(user, type, notificable = nil, options = {})
      options.merge!(
        type: type.to_sym,
        notificable: notificable,
        notificable_type: notificable.presence && notificable.class.to_s,
        notificable_id: notificable.presence && notificable.try(:id)
      )

      if Application::Config.enabled?(:create_system_notification_async)
        user = (user.is_a?(User) ? user.try(:id) : user)
        ::Workers::V1::NotificationCreateWorker.perform_async(user, options)
      else
        create_system_notification(user, type, notificable, options)
      end
    end

    def user_preference_on?(user, preference_key)
      return false unless user

      user.preference_on?(preference_key)
    end

    def user_preference_off?(user, preference_key)
      !user_preference_on?(user, preference_key)
    end
  end

  # We can open directly the `NiftyServices::BaseService` and include module
  # there, but we can choose to not do this just with a litte repetition, but
  # much more isolated and independent code ;)
  class BaseService < ::NiftyServices::BaseService
    include ServiceExtensions
  end

  class BaseCrudService < ::NiftyServices::BaseCrudService
    include ServiceExtensions
  end

  class BaseCreateService < ::NiftyServices::BaseCreateService
    include ServiceExtensions
  end

  class BaseUpdateService < ::NiftyServices::BaseUpdateService
    include ServiceExtensions
  end

  class BaseDeleteService < ::NiftyServices::BaseDeleteService
    include ServiceExtensions
  end

  class BaseActionService < ::NiftyServices::BaseActionService
    include ServiceExtensions
  end
end


