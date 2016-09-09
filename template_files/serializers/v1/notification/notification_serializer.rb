module Serializers
  module V1
    class NotificationSerializer < SimpleNotificationSerializer
      attributes :formatted_body, :metadata
    end
  end
end
