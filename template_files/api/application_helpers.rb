require 'simple_services'

module API
  module Helpers
    module ApplicationHelpers

      include SimpleServices::Integrations::Grape

      before do
        set_locale
        set_origin
      end

    end
  end
end
