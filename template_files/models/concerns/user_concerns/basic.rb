module UserConcerns
  module Basic

    extend ActiveSupport::Concern

    EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

    included do
      has_one :origin, as: :originable

      has_one :address, as: :addressable

      validates :first_name, :email, presence: true

      accepts_nested_attributes_for :address

      validates :email, uniqueness: true, on: [:create]

      validates :email, format: { with: EMAIL_REGEXP }, if: -> {
        self.email.present?
      }

      validates :username, uniqueness: true, on: :create

      after_initialize  :set_defaults
      before_validation  :set_defaults

      before_save :clear_attributes_for_user

      def name=(full_name)
        names = full_name.split(/\s/)
        self.first_name = names.shift
        self.last_name  = names.join(' ')
      end

      def name
        [self.first_name, self.last_name].join(' ')
      end

      private
      def set_defaults
      end

      def clear_attributes_for_user
      end

    end

  end
end
