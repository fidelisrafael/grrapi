module Workers
  module V1
    class ParseDeviceCreateWorker

      include Sidekiq::Worker

      sidekiq_options :retry => 5, queue: :parse

      sidekiq_retry_in { |count| count * 60 }

      def perform(user_id, device_data, delete_old_devices = false)
        user = ::User.find_by(id: user_id)

        if user
          device_data = device_data.deep_symbolize_keys!

          device_platform = device_data[:device] ?
                              device_data[:device].fetch(:platform, nil) :
                              device_data[:platform]

          begin
            if delete_old_devices && device_platform.present?
              if ::UserDevice::VALID_PLATFORMS.values.member?(device_platform)
                user.devices.send(device_platform).each do |device|
                  ::Services::V1::Parse::DeviceDeleteService.new(user, device).execute
                end
              end
            end
          rescue Exception => e
            Rollbar.error(e)
          end

          service = ::Services::V1::Parse::DeviceCreateService.new(user, device_data)
          service.execute
        end
      end
    end
  end
end
