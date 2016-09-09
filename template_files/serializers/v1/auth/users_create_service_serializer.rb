module Serializers
  module V1
    class Auth::UserCreateServiceSerializer < ActiveModel::Serializer

      root false

      attributes :data, :auth_data, :new_user

      def data
        serializer = ::Serializers::V1::SimpleUserSerializer.new(object.user)
        serializer.serializable_hash.merge(user_data)
      end

      def auth_data
        {
          auth_token: object.user_auth_token,
          provider: object.user_auth_provider,
          expires_at: object.user_auth_expires_at
        }
      end

      def user_data
        {
          new_user: new_user,
          account_activated: object.user.account_activated?
        }
      end


      def new_user
        object.new_user?
      end
    end
  end
end
