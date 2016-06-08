module API
  module Helpers
    module V1
      module AuthHelpers

        def authentication_create_service_name
          'Auth::CreateService'
        end

        def authentication_token_validate_service_name
          'Auth::TokenValidateService'
        end

      end
    end
  end
end
