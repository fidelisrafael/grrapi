module Workers
  module V1
    class ParseDeviceSaveWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :parse

      sidekiq_retry_in { |count| count * 60 }

      def perform(device_id)
        device = ::UserDevice.find_by(id: device_id)

        Services::V1::Parse::DeviceSaveService.new(device).execute
      end
    end
  end
end
