module API
  class Base < Grape::API

    include API::Helpers::CacheDSL

    helpers API::Helpers::CacheHelpers
    helpers API::Helpers::ApplicationHelpers
    helpers API::Helpers::AuthHelpers

    prefix Application::Config.api_prefix_path if Application::Config.enabled?(:prefix_api_path)

    format :json

    before do
      set_locale
      set_origin
    end

    mount API::V1::Base
  end
end
