module Workers
  module V1
    class ParseDeviceDeleteWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :parse

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, device_id)
        user = User.find_by(id: user_id)

        if user
          device = user.devices.find_by(id: device_id)
          ::Services::V1::Parse::DeviceDeleteService.new(user, device).execute
        end
      end
    end
  end
end
