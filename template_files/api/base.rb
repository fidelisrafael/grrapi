module API
  class Base < Grape::API

    helpers API::Helpers::PaginateHelpers

    helpers API::Helpers::ApplicationHelpers

    prefix Application::Config.api_prefix_path if Application::Config.enabled?(:prefix_api_path)

    format :json

    before do
      set_locale
      set_origin
    end

    mount API::V1::Base
  end
end
