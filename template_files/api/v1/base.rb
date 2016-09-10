module API
  module V1
    class Base < API::Base
      include Grape::Kaminari

      helpers API::Helpers::V1::PaginateHelpers
      helpers API::Helpers::V1::ApplicationHelpers
      helpers API::Helpers::V1::AuthHelpers

      version 'v1'

      add_swagger_documentation(
        base_path: "/api",
        hide_format: true,
        hide_documentation_path: true,
        api_version: 'v1'
      )

      mount V1::Routes::Cities
      mount V1::Routes::States

      mount V1::Routes::Users
      mount V1::Routes::UsersAuth
      mount V1::Routes::UsersAuthSocial
      mount V1::Routes::UsersMe
      mount V1::Routes::UsersMeCacheable
    end
  end
end
