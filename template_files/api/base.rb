module API
  class Base < Grape::API

    include ::API::Helpers::ApplicationHelpers

    prefix 'api' if Application::Config.enabled?(:prefix_api_path)

    format :json

    mount API::V1::Base
  end
end
