module Services
  module V1
    module Auth
      module AuthProviders
        class Facebook < AuthProviders::Base

          PROVIDER_ATTRIBUTES  = [:email, :first_name, :last_name]
          PROVIDER_REQUEST_URL = "https://graph.facebook.com/%s/?fields=%s&access_token=%s"
          PROVIDER_AVATAR_URL  = "https://graph.facebook.com/%s/picture?type=%s"

          def memoized_fetch_user_data(scope = 'me')
            @users_data ||= {}
            @users_data[scope.to_sym] ||= fetch_user_data(scope)
          end

          def oauth_provider_uid
            data = memoized_fetch_user_data
            data.is_a?(Hash) ? data[:oauth_provider_uid] : nil
          end

          def provider_name
            :facebook
          end

          def provider_uid_key
            :id
          end

          def provider_remote_avatar_url(user_id, type = 'large')
            PROVIDER_AVATAR_URL % [user_id, type]
          end

          private
          def error_code_key
            :fb_error_message
          end

          def error_message_key
            :fb_error_code
          end

          def provider_request_url(access_token, uuid = 'me', params = 'name, first_name, last_name, email, birthday')
            PROVIDER_REQUEST_URL % [uuid, params, access_token]
          end

          def normalized_user_data_from_provider(provider_data)
            birthday = birthday_date_from_facebook(provider_data['birthday'])

            user_data = provider_data
                        .slice(*PROVIDER_ATTRIBUTES.map(&:to_s))
                        # .merge(age: calculate_age_from_birthday(birthday))

            base_user_data.merge(user_data)
          end

          def calculate_age_from_birthday(birthday)
            return nil if birthday.blank?

            current = Date.today

            # if user birthday yet NOT was happened this year
            # remove -1 from calc
            (current.year - birthday.year) + (
              (current.month >= birthday.month && current.day >= birthday.day) ? 0 : -1)
          end

          # facebook returns the date in a difficult way to parse
          def birthday_date_from_facebook(birthday)
            return Date.today if birthday.blank?

            date = birthday.to_s.gsub(/(\d{2})\/(\d{2})\/(\d{4})/, '\\2/\\1/\\3')

            Date.parse(date) rescue Date.yesterday
          end
        end
      end
    end
  end
end
