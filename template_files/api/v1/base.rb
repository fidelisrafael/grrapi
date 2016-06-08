module API
  module V1
    class Base < API::Base

      helpers API::Helpers::V1::ApplicationHelpers
      helpers API::Helpers::V1::AuthHelpers

      version 'v1'

      add_swagger_documentation(
        base_path: "/api",
        hide_format: true,
        hide_documentation_path: true,
        api_version: 'v1'
      )

      mount V1::Routes::UsersAuth
    end
  end
end
