# encoding: UTF-8

class Authorization < ActiveRecord::Base

  PROVIDERS = Application::Config.authentication_providers.dup

  DEFAULT_EXPIRATION_TIME = 432000 # 5.days - Default config if not set in config/application.yml

  EXPIRATION_TIME_LEFT_TO_UPDATE = (Application::Config.authentication_token_expiration_seconds || DEFAULT_EXPIRATION_TIME).to_i

  validates :token, presence: true
  validates :provider, presence: true, inclusion: PROVIDERS.map(&:to_s)

  validate :owner_user_must_be_activated_account

  belongs_to :user

  before_validation :normalize_provider, :generate_token

  before_create :set_expiration_date

  def expired?
    Time.zone.now >= expires_at
  end

  def valid_access?
    return false if expired?
    return true
  end

  def update_token_expires_at(force=false)
    if eligible_for_expiration_update?(force)
      self.update_attribute(:expires_at, expiration_date_from_now)
    end
  end

  def eligible_for_expiration_update?(force=false)
    force || ((Time.zone.now + EXPIRATION_TIME_LEFT_TO_UPDATE) >= expires_at)
  end

  private
  def set_expiration_date
    self.expires_at = expiration_date_from_now
    nil
  end

  def expiration_date_from_now
    Time.zone.now + Application::Config.session_duration.to_i.seconds
  end

  def generate_token
    return self if self.token.present?

    begin
      self.token = SecureRandom.hex
    end while self.class.exists?(token: token)
  end

  def normalize_provider
    self.provider = self.provider.to_s.downcase
  end

  def owner_user_must_be_activated_account
    return self if Application::Config.disabled?(:force_account_activation_to_enable_login)

    if self.user && self.user.account_deactivated?
      self.errors.add(:user, I18n.t('errors.user_account_not_activated'))
    end
  end
end
