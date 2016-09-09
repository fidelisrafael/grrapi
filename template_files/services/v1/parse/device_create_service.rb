module Services
  module V1
    module Parse
      class DeviceCreateService < Parse::BaseService

        attr_reader :device

        WHITELIST_PARAMETERS = [
          :installation_id,
          :token,
          :platform
        ]

        def execute
          execute_action do
            @device = build_device
            new_device = @device.new_record?

            if user_can_create_device?
              if save_device(device)
                create_origin_async(device)
                new_device ? success_created_response : success_response
              else
                unprocessable_entity_error!(@device.errors)
              end
            else
              unprocessable_entity_error!('users.device_already_registered')
            end
          end
        end

        private
        def save_device(device)
          return false unless device

          begin
            device.save!
          rescue Exception => e
            return false
          end
        end

        def can_execute?
          return valid_user?
        end

        def after_success
          register_device_in_parse(@device)
        end

        def build_device
          device = user.devices.find_or_initialize_by(device_params)
        end

        def device_params
          (@options[:device] || {}).slice(*WHITELIST_PARAMETERS).to_h
        end

        def user_can_create_device?
          return false unless valid_device?

          !UserDevice.exists?(device_params)
        end

        def valid_device?
          return device_params.any?
        end
      end
    end
  end
end
