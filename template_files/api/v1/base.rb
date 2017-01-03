module API
  module V1
    class Base < API::Base
      version 'v1'

      helpers API::V1::Helpers::PaginateHelpers
      helpers API::V1::Helpers::ApplicationHelpers

      add_swagger_documentation(
        base_path: "/api",
        hide_format: true,
        hide_documentation_path: true,
        api_version: 'v1'
      )
    end
  end
end
