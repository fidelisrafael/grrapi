module API
  class Base < Grape::API
    format :json

    helpers API::Helpers::ApplicationHelpers

    prefix Application::Config.api_prefix_path if Application::Config.enabled?(:prefix_api_path)

    before do
      set_locale
      set_origin
    end

    mount API::V1::Base
  end
end
