 require_relative '../address/address_serializer'

module Serializers
  module V1
    class CurrentUserSerializer < SimpleUserSerializer

      has_one :address, serializer: AddressSerializer

      attributes :fullname, :email, :oauth_provider, :oauth_provider_uid,
                 :phone_area_code, :phone_number,
                 :terms_of_user_accepted_at, :activated_at, :login_status_historic,
                 :preferences


      def terms_of_user_accepted_at
        object.tof_accepted_at
      end
    end
  end
end
