module Accessable

  extend ActiveSupport::Concern

  def self.user_can_create_record?(user)
    user.admin?
  end

  def user_can_access?(user)
    user.admin? || owner?(user)
  end

  def user_can_manage?(user)
    user.admin? || owner?(user)
  end

  def user_can_update?(user)
    user_can_manage?(user)
  end

  def user_can_delete?(user)
    user_can_manage?(user)
  end

  def user_can_restore?(user)
    user.admin?
  end

  def owner?(user)
    self.user_id == (user.is_a?(Integer) ? user : user.id)
  end
end
