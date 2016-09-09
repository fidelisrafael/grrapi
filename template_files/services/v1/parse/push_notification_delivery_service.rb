module Services
  module V1
    module Parse
      class PushNotificationDeliveryService < Parse::BaseService

        attr_reader :user, :notification_data, :total_sent

        PUSH_DATA_WHITELIST_ATTRIBUTES = [
          :receiver_user_id,
          :sender_user_id,
          :notificable_id,
          :notificable_type,
          :message,
          :notification_type,
          :metadata
        ]

        def initialize(user, notification_data, options = {})
          @notification_data = notification_data
          super(user, options)
        end

        def execute
          return false if @executed

          if can_send_push_notification?
            send_push_notification

            return success?
          end

          return false
        end

        def can_send_push_notification?
          return false unless valid_user?

          unless valid_notification_data?
            return unprocessable_entity_error!('push.invalid_data')
          end

          @executed = true
        end

        private
        def send_push_notification
          if execute_using_saved_devices?
            with_user_devices do |device|
              push = push_for_device(device)
              delivery_push(push)
            end
          else
            push = push_for_user
            delivery_push(push)
          end
        end

        def valid_notification_data?
          return false unless notification_data.is_a?(Hash)

          notification_data.keys.map(&:to_sym).member?(:alert)
        end

        def execute_using_saved_devices?
          return options[:using_saved_devices].present?
        end

        def with_user_devices
          devices = @user.devices.valid_for_parse_push

          devices.each do |device|
            yield device
          end

          devices
        end

        def push_for_device(device)
          user    = device.user
          channel = user.channel_for_specific_device(device)

          build_push_notification(device.platform, nil, channel)
        end

        def push_for_user
          build_push_notification(nil, push_channel_for_user)
        end

        def push_data
          notification_data.symbolize_keys.slice(:alert, :data)
        end

        def delivery_push(push)
          begin
            @delivery_response = push.save
          rescue Exception => e
            Rollbar.error(e)
            @delivery_response = { 'result' => false }
          end

          success_delivery  = @delivery_response['result'] == true

          if success_delivery
            @total_sent = (@total_sent || 0).next
            success_created_response
          else
            unprocessable_entity_error(@delivery_response)
          end
        end

        def push_channel_for_user
          "user_id_#{user.id}"
        end

        def build_push_notification(type, channel = nil, query = nil)
          push = parse_client.push(push_data, channel)
          push.type = type if channel.blank?

          if query.is_a?(::Parse::Query)
            push.type  = nil
            push.where = query.where
          end

          push
        end

        def after_success
          create_push_notification_history
        end

        def create_push_notification_history
          ::Workers::V1::PushNotificationHistoricCreateWorker.perform_async(user.id, push_data)
        end
      end
    end
  end
end

