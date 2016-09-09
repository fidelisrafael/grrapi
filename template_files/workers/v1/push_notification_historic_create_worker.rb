module Workers
  module V1
    class PushNotificationHistoricCreateWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :push_notifications

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, push_data = {})
        user = User.find_by(id: user_id)

        return false unless user
        return false unless push_data

        push_data = push_data.deep_symbolize_keys!

        whitelist_attrs = ::Services::V1::Parse::PushNotificationDeliveryService::PUSH_DATA_WHITELIST_ATTRIBUTES

        data = ((push_data && push_data[:data]) || push_data).slice(*whitelist_attrs)
        data[:delivered_at] = Time.zone.now
        data[:notificable_type] = data[:notificable_type].try(:classify)

        user.push_notification_historics.create!(data)
      end
    end
  end
end
