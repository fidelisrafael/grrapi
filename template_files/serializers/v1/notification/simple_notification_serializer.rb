module Serializers
  module V1
    class SimpleNotificationSerializer < ActiveModel::Serializer

      attributes :id, :sender_user_id, :notification_type,
                 :read?, :read_at, :updated_at
    end
  end
end
