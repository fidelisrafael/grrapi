module Services
  module V1
    class Users::ProfileImageUpdateService < BaseUpdateService

      WHITELIST_ATTRIBUTES = [
        :profile_image
      ]

      record_type ::User

      def images_url
        { default: @user.profile_image_url }.merge(@user.profile_images)
      end

      private
      def record_attributes_hash
        (@options[:user] || {}).to_h
      end

      def record_attributes_whitelist
        WHITELIST_ATTRIBUTES
      end

      def user_can_update_record?
        @user == @record # only yourself can update yourself
      end

      def after_success
        @user.reload
      end

    end
  end
end
