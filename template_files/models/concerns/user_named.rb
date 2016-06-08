module UserNamed

  extend ActiveSupport::Concern

  included do
    before_save :set_username
  end

  def fullname
    [self.try(:first_name) || self.try(:name), self.try(:last_name)].compact.join(' ')
  end

  private
  def set_username
    return true if self.username.present? && self.persisted?

    current_index = nil

    begin

      username      = username_from_name(current_index)
      current_index = ((current_index ||= 1) + 1)

    end while self.class.exists?(username: username)

    self.username = username

    nil
  end

  def normalize_username(username)
    username.to_s.parameterize.gsub(/(\-+)/im, '_')
  end

  def username_from_name(index)
    username = [self.username || self.fullname, index].compact.join
    normalize_username(username)
  end

end
