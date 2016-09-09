module Workers
  module V1
    class PushNotificationDeliveryWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :push_notifications

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, push_data = {})
        user = User.find_by(id: user_id)

        return false unless user

        send_push_notification(user, push_data)
      end

      def send_push_notification(user, push_data)
        service = ::Services::V1::Parse::PushNotificationDeliveryService.new(user, push_data)
        service.execute
      end
    end
  end
end
