module Services
  module V1
    module Parse
      class DeviceSaveService < Parse::BaseService

        attr_reader :device

        def initialize(device, options = {})
          @device = device
          super(@device.try(:user), options)
        end

        def execute
          execute_action do
            if @device.parse_object_id.present?
              installation = begin
                response = parse_client.installation(@device.parse_object_id).get
              rescue
                nil
              end
            else
              installation = parse_client.installation.tap do |i|
                i.device_token = device.token
                i.device_type  = device.platform
                i.channels     = channels_for_device(device)
                i.push_type    = :gcm if device.android?
              end
            end

            begin
              last_updated_at = DateTime.parse(installation['updatedAt']) if installation['updatedAt']
              response = installation.save
              current_updated = DateTime.parse(response['updatedAt']) if response['updatedAt']

              if updating_existing?(last_updated_at, current_updated)
                success_response
              else
                success_created_response
              end

              if response
                response_attributes = response
                                      .symbolize_keys
                                      .slice(:objectId, :installationId)
                                      .transform_keys {|key| ['parse', key.to_s.underscore].join('_') }
                device.update_attributes(response_attributes)
              end
            rescue => e
              Rollbar.error(e)
              forbidden_error!('devices.error_saving_in_parse')
              device.update_attribute(:parse_object_id, nil)
            end
          end
        end

        def can_execute?
          @device.present?
        end

        def updating_existing?(last_updated_at, current_updated)
          return false if last_updated_at.blank?

          current_updated && (current_updated >= last_updated_at)
        end
      end
    end
  end
end
