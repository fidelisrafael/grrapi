class User < ActiveRecord::Base
  # soft delete
  acts_as_paranoid

  # ACL
  include Accessable

  # add callbacks to generate user's username based on `name`, `first_name` and/or `last_name`
  include UserNamed

  # Basic user validations and setup
  include UserConcerns::Basic

  # User auth related setup (authentication, account confirmation, password recovery, account block)
  include UserConcerns::Auth

  # User preferences handling
  include UserConcerns::Preferences

  # User profile images
  include UserConcerns::ProfileImage

  # Notifications
  include UserConcerns::Notifications
end
