module UserConcerns
  module Auth

    extend ActiveSupport::Concern

    PASSWORD_REGEXP = /\A(?=.*[a-zA-Z])(?=.*[0-9]).{6,}\z/i

    MAX_ALLOWED_LOGIN_ATTEMPTS    = (Application::Config.max_allowed_login_attempts || 5).to_i
    LOGIN_BLOCK_INTERVAL_FROM_NOW = (Application::Config.login_block_period || 1.day).to_i

    included do
      has_secure_password

      scope :not_activated, -> { where(activated_at: nil) }
      scope :account_activated, -> { where.not(activated_at: nil) }

      has_many :authorizations

      # validate password for new user or revalidate password if changed
      validates :password, :password_confirmation, presence: true,
                :length => { :minimum => 5 },
                :format => { with: PASSWORD_REGEXP },
                :if => :needs_password_validation?

      validates :password, confirmation: true, if: :needs_password_validation?

      before_save :generate_activation_token

      def self.authenticate(email, password)
        return false unless email && password

        user = User.find_by(email: email)
        user.try(:authenticate, password)
      end

      def activate_account!
        return true if self.account_activated?

        self.update_attributes(activated_at: Time.zone.now)
      end

      def deactivate_account!
        self.update_attributes(activated_at: nil, activation_token: nil)
      end

      def account_activated?
        [self.activation_token, self.activated_at].all?
      end

      def account_deactivated?
        !account_activated?
      end

      def send_account_activation_mail!
        UsersMailer.activate_account(self).deliver

        self.update_attribute(:activation_sent_at, Time.zone.now)
      end

      def from_oauth?
        self.oauth_provider.present?
      end

      def first_login_on_provider?(provider)
        return false unless account_activated?

        set_login_status(provider)

        self.login_status[provider.to_s].to_i == 1
      end

      def update_login_count_from_provider!(provider)
        return false unless account_activated?

        set_login_status(provider)

        self.login_status[provider.to_s] += 1

        self.update_attribute(:login_status, self.login_status)
      end

      def set_login_status(provider)
        self.login_status ||= Hash.new { 0 }
        self.login_status[provider.to_s] ||= 0

        self.login_status
      end

      def reset_password!
        self.reset_password_token   = [self.id, SecureRandom.hex].join
        self.reset_password_sent_at = Time.now
        self.save!
      end

      def update_password(new_password, save=true)
        self.password             = self.password_confirmation = new_password
        self.password_reseted_at  = Time.now
        self.reset_password_token = nil
        self.authorizations.delete_all
        self.save if save
      end

      def block(interval, save = false)
        return false if login_block_disabled?

        self.login_attempts = 0
        self.blocked_until = Time.zone.now + interval

        save ? self.save : self
      end

      def block!(interval)
        block(interval, true)
      end

      def blocked?
        blocked_until.present? && (blocked_until > Time.zone.now)
      end

      def unblock!
        return false if login_block_disabled?
        self.update_attributes(blocked_until: nil, login_attempts: 0)
      end

      def reached_max_login_attempts?
        return false if login_block_disabled?
        return false if self.login_attempts.blank?

        self.login_attempts >= MAX_ALLOWED_LOGIN_ATTEMPTS
      end

      def update_login_attempts_counter
        return false if login_block_disabled?
        return false if blocked?

        if reached_max_login_attempts?
          self.block!(LOGIN_BLOCK_INTERVAL_FROM_NOW)
        else
          self.increment!(:login_attempts)
        end
      end

      def generate_activation_token
        return self if self.activation_token

        begin
          self.activation_token = SecureRandom.hex
        end while self.class.exists?(activation_token: activation_token)

        nil
      end

      private
      def login_block_enabled?
        Application::Config.enabled?(:enable_max_login_attempts_block)
      end

      def login_block_disabled?
        !login_block_enabled?
      end

      def needs_password_validation?
        return false if self.oauth_provider.present?
        self.new_record? || self.password_digest_changed? || (self.password_digest_changed? && self.password.blank?)
      end
    end
  end
end
