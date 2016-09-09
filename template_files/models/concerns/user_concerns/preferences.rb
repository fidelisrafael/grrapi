module UserConcerns
  module Preferences

    extend ActiveSupport::Concern

    PREFERENCES_TEMPLATE = JSON.load(Rails.root.join('config', 'user_preferences.json'))

    included do
      after_save  :create_default_preferences

      def create_default_preferences(force=false)
        return false if !force && self.preferences && self.preferences.any?
        self.update_attributes(preferences: PREFERENCES_TEMPLATE)
      end

      def preference_on?(key)
        create_default_preferences if self.preferences.blank?

        return false unless allowed_preference_key?(key)

        !!value_for_preference(self.preferences[key.to_s])
      end

      def preference_off?(key)
        !preference_on?(key)
      end

      def update_preference_key(key, value, save=true)
        return false unless allowed_preference_key?(key)

        create_default_preferences

        self.preferences[key.to_s] = value_for_preference(value)
        self.preferences.transform_values!(&:to_s)

        self.save if save
      end

      def allowed_preference_key?(key)
        return false if key.blank?
        @_allowed_preference_keys ||= PREFERENCES_TEMPLATE.keys.map(&:to_sym)
        @_allowed_preference_keys.member?(key.to_s.to_sym)
      end

      def value_for_preference(value)
        value == false || value == "false" ? false : true
      end

    end
  end
end
