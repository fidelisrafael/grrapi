module Services
  class BaseService < ::SimpleServices::BaseService
  end
  class BaseCrudService < ::SimpleServices::BaseCrudService
  end
end


[:BaseService, :BaseCrudService].each do |service|
  klasses = ["Services::#{service}", "SimpleServices::#{service}"].each do |klass|
    klass.constantize.class_eval do
      def valid_user?
        valid_object?(@user, User)
      end
    end
  end
end
