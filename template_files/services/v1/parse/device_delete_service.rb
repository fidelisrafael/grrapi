module Services
  module V1
    module Parse
      class DeviceDeleteService < Parse::BaseService

        attr_reader :device

        def initialize(user, device, options = {})
          @device = device
          super(user, options)
        end

        def execute
          execute_action do
            if can_execute?
              installation = parse_client.installation(device.parse_object_id)

              begin
                device.really_destroy!
                installation.parse_delete
              rescue => e
                Rollbar.error(e)
                forbidden_error!('devices.error_deleting_in_parse')
              end
            else
              return forbidden_error!('devices.user_cant_delete')
            end
          end
        end

        def can_execute?
          return false unless @device

          @device.user_can_delete?(@user)
        end


      end
    end
  end
end
