module Services
  module V1
    module Auth
      module AuthProviders
        class GooglePlus < AuthProviders::Base

          PROVIDER_ATTRIBUTES  = [:email]
          PROVIDER_REQUEST_URL = "https://www.googleapis.com/plus/v1/people/%s?access_token=%s"

          def memoized_fetch_user_data(scope = 'me')
            @users_data ||= {}
            @users_data[scope.to_sym] ||= fetch_user_data(scope)
          end

          def provider_name
            :google_plus
          end

          def provider_uid_key
            :id
          end

          def provider_request_url(access_token, uuid = 'me')
            PROVIDER_REQUEST_URL % [uuid, access_token]
          end

          def provider_remote_avatar_url(user_id, size='300')
            image_data = (@auth_provider_data || {})['image']
            image_url  = image_data && image_data['url'] || ''

            image_url.sub(/sz=(\d+)/i, "sz=#{size}")
          end

          private
          def normalized_user_data_from_provider(provider_data)
            pd = provider_data

            email = pd['email'] || pd['emails'] && pd['emails'].first.try(:[],'value')
            name_data = pd['name']
            first_name, last_name = name_data['givenName'], name_data['familyName']

            age_range = pd['ageRange'] ? pd['ageRange']['max'] || pd['ageRange']['min'] : nil

            user_data = provider_data
                        .slice(*PROVIDER_ATTRIBUTES.map(&:to_s))
                        .merge(email: email, first_name: first_name, last_name: last_name)
                        # .merge(age: age_range)

            base_user_data.merge(user_data)
          end
        end
      end
    end
  end
end
