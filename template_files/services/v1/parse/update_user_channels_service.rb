module Services
  module V1
    module Parse
      class UpdateUserChannelsService < Parse::BaseService

        def execute
          if valid_user?
            update_channels_for_user
          else
            not_found_error('users.not_found')
          end

          success?
        end

        def update_channels_for_user
          channels = @user.channels_for_notification

          user_devices.each do |device|
            channels.concat(user.channels_for_device(device))
          end

          if update_installations_channels(channels)
            success_response
          else
            unprocessable_entity_error('undefined')
          end
        end

        def update_installations_channels(channels)
          updates = []

          find_installations.each do |installation|
            updates << update_installation_channel(installation, channels)
          end

          updates.all? {|u| u['deviceToken'].present? }
        end

        def update_installation_channel(installation, channels, save=true)
          installation.channels = channels
          save ? installation.save : installation
        end

        def find_installations
          @installations = []

          user_devices.each do |device|
            @installations.push(find_parse_installation(device.parse_object_id))
          end

          @installations.compact
        end

        def user_devices
          @user_devices ||= @user.devices.valid_for_parse_push
        end

        def find_parse_installation(object_id)
          begin
            parse_client.installation(object_id).get
          rescue => e
            Rollbar.error(e)
            nil
          end
        end

      end
    end
  end
end
