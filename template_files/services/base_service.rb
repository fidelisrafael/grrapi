module Services
  class BaseService < ::SimpleServices::BaseService

    def valid_user?
      valid_object?(@user, User)
    end

  end
end
