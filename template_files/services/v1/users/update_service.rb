module Services
  module V1
    class Users::UpdateService < BaseUpdateService

      concern :Users, :CreateUpdate

      WHITELIST_ATTRIBUTES = [
        :name,
        :first_name,
        :last_name,
        :profile_image,
        :password,
        :password_confirmation
      ]

      record_type ::User

      def changed_attributes
        changes = super

        changes.push(:password) if changes.exclude?(:password) && changed_password?

        changes
      end

      def changed_password?
        return false unless @last_record
        @last_record.password_digest != @record.password_digest
      end

      def record_attributes_hash
        (@options[:user] || {}).to_h
      end

      def record_attributes_whitelist
        WHITELIST_ATTRIBUTES
      end

      def user_can_update_record?
        return false unless @user == @record # only yourself can update yourself

        return perform_validations
      end

    end
  end
end
