module Application
  class Helpers

    include ActionView::Helpers::SanitizeHelper

    def self.method_missing(method_name, *arguments, &block)
      self.new.send(method_name, *arguments, &block)
    end
  end
end
