class UserDevice < ActiveRecord::Base

  include Accessable

  acts_as_paranoid

  VALID_PLATFORMS = {
    ios: "ios",
    android: "android"
  }

  VALID_PLATFORMS.each do |key, value|
    scope key, -> { where(platform: value) }

    define_method("#{key}?") do
      self.platform == value
    end
  end

  scope :valid_for_parse_push, -> {
    where.not(parse_object_id: nil)
  }

  belongs_to :user

  has_one :origin, as: :originable

  validates :user_id, :token, :identifier, :platform, presence: true

  validates :token, uniqueness: true
  validates :identifier, uniqueness: true

  validates :platform, inclusion: VALID_PLATFORMS.values

  after_initialize :set_default_identifier

  private

  def set_default_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
