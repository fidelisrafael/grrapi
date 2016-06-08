class User < ActiveRecord::Base
  # add callbacks to generate user's username based on `name`, `first_name` and/or `last_name`
  include UserNamed

  # Basic user validations and setup
  include UserConcerns::Basic

  # User auth related setup (authentication, account confirmation, password recovery, account block)
  include UserConcerns::Auth
end
