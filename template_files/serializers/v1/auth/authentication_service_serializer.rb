module Serializers
  module V1
    class Auth::AuthenticationServiceSerializer < ActiveModel::Serializer

      root false

      attributes :user_data, :auth_data, :new_user

      def user_data
        {
          id: object.user_id,
          username: object.user_username,
          first_name: object.user.first_name,
          last_name: object.user.last_name,
          full_name: object.user.fullname,
          name: object.user.name,
          oauth_provider: object.user_oauth_provider,
          oauth_provider_uid: object.user_oauth_provider_uid,
          new_user: new_user,
          account_activated: object.user.account_activated?
        }
      end

      def auth_data
        {
          auth_token: object.user_auth_token,
          provider: object.user_auth_provider,
          expires_at: object.user_auth_expires_at
        }
      end

      def new_user
        object.new_user?
      end
    end
  end
end
