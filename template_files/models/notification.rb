class Notification < ActiveRecord::Base

  # soft delete
  acts_as_paranoid

  default_scope { order(created_at: :desc) }

  TYPES = JSON.load(Rails.root.join('config', 'notifications_types.json'))

  READ_STATUS = {
    read: true,
    unread: false
  }

  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }

  belongs_to :notificable, polymorphic: true

  belongs_to :receiver_user, foreign_key: :receiver_user_id, class_name: 'User'
  belongs_to :sender_user,   foreign_key: :sender_user_id  , class_name: 'User'

  has_one :origin, as: :originable

  after_initialize :set_defaults

  validates :receiver_user_id, :notification_type, presence: true

  validates :notificable_type, :notificable_id, presence: true

  validates :notification_type, inclusion: TYPES.map(&:to_s)

  validate :notified_user_is_not_sender_user, on: :create

  def mark_as_read
    self.update_attribute(:read_at, Time.now)
  end

  def read?
    read_at.present?
  end

  def unread?
    !read?
  end

  alias :read :read?
  alias :unread :unread?

  def formatted_body
    self.body % notification_meta rescue self.body
  end

  def body
    @body ||= I18n.t(self.notification_type, scope: 'notifications')
  end

  def metadata
    metadata = { sender_user_id: self.sender_user_id }

    return metadata if self.notificable_id.blank?

    metadata.merge!(self.slice("notificable_id", "notificable_type"))

    if self.notificable.respond_to?(:profile_images)
      metadata.merge!(images: self.notificable.profile_images)
    end

    metadata
  end

  private
  def notification_meta
    @_receiver_user ||= self.receiver_user
    @_sender_user   ||= self.sender_user
    @_notificable   ||= self.notificable

    if @_notificable.blank? && self.notificable_type.present?
      @_notificable = self.notificable_type.constantize.try(:with_deleted).try(:find, self.notificable_id)
    end

    Application::NotificationMetaParse.new(@_receiver_user, @_sender_user, @_notificable).parse
  end

  def notified_user_is_not_sender_user
    if self.sender_user_id == self.receiver_user_id
      self.errors.add(:email, I18n.t('errors.notifications.user_cant_notify_yourself'))
    end
  end

  def set_defaults
  end
end
