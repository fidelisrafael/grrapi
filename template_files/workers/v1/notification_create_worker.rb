module Workers
  module V1
    class NotificationCreateWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :system_notifications

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, notification_data = {})
        user = User.find_by(id: user_id)

        return false unless user

        service = ::Services::V1::Users::NotificationCreateService.new(user, notification_data)
        service.execute
      end

    end
  end
end
