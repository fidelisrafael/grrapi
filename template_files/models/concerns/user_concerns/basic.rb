module UserConcerns
  module Basic

    extend ActiveSupport::Concern

    EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    VALID_PROFILES_TYPES = {
      :common_user => "common_user",
      :staff       => "staff",
      :admin       => "admin"
    }

    included do
      VALID_PROFILES_TYPES.each do |key, value|
        scope key, -> { where(profile_type: value) }

        define_method("is_#{key}?") do
          self.profile_type.to_s == value.to_s
        end

        alias :"#{key}?" :"is_#{key}?"
      end

      has_one :origin, as: :originable

      validates :first_name, :email, presence: true

      validates :email, uniqueness: true, on: [:create]

      validates :email, format: { with: EMAIL_REGEXP }, if: -> {
        self.email.present?
      }

      validates :username, uniqueness: true, on: :create

      validates :profile_type, presence: true, inclusion: VALID_PROFILES_TYPES.values

      after_initialize  :set_defaults
      before_validation  :set_defaults

      before_save :clear_attributes_for_user

      def name=(full_name)
        names = full_name.split(/\s/).reject {|v| v.empty? }
        self.first_name = names.shift
        self.last_name  = names.join(' ')
      end

      def name
        [self.first_name, self.last_name].join(' ')
      end

      def obfuscated_email
        email
      end

      def owner?(user)
        self.id == (user.is_a?(Integer) ? user : user.id)
      end

      private
      def set_defaults
        self.profile_type ||= VALID_PROFILES_TYPES[:common_user]
      end

      def clear_attributes_for_user
      end

    end

  end
end
