module Serializers
  module V1
    class CurrentUserSerializer < SimpleUserSerializer

      attributes :fullname, :email, :oauth_provider, :oauth_provider_uid,
                 :terms_of_user_accepted_at, :activated_at, :login_status_historic,
                 :preferences


      def terms_of_user_accepted_at
        object.tof_accepted_at
      end
    end
  end
end
