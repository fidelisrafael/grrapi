module Services
  module V1
    class Users::PreferencesUpdateService < BaseUpdateService

      record_type ::User

      def changed_attributes
        [:preferences]
      end

      private
      def record_attributes_whitelist
        [:preferences]
      end

      def record_attributes_hash
        preferences_hash = filter_hash(@options, [:preferences])
        clear_preferences(preferences_hash[:preferences] || preferences_hash)
      end

      def update_record
        record_attributes_hash.each do |key, value|
          @user.update_preference_key(key, value, false)
        end

        @user.save

        @user
      end

      def clear_preferences(preferences_hash)
        hash = preferences_hash.keep_if do |key, _|
          user.allowed_preference_key?(key)
        end.to_h.symbolize_keys
      end

      def user_can_update_record?
        @record.id == @user.id
      end
    end
  end
end
