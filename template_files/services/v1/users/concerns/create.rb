module Services
  module V1
    module Users
      module Concerns
        module Create

          extend ActiveSupport::Concern

          WHITELIST_ATTRIBUTES = [
            :name,
            :first_name,
            :last_name,
            :email,
            :password,
            :password_confirmation,
            :tof_accepted
          ]

          ADDRESS_WHITELIST_ATTRIBUTES = [
            :city_id,
            :street,
            :number,
            :district,
            :complement,
            :zipcode
          ]

          POSTMON_ENDPOINT = 'http://api.postmon.com.br/v1/cep/%s'

          DEFAULT_PROVIDER = :site

          included do
            def user_params
              @user_params ||= filter_hash(attributes_hash, WHITELIST_ATTRIBUTES)
              @user_params[:password_confirmation] ||= @options[:user] && @options[:user].fetch(:password_confirmation, true)

              @user_params
            end

            def attributes_hash
              @options[:user]
            end

            def non_change_trackable_attributes
              [:password_confirmation]
            end

            def updating_profile_image?
              attributes_hash && attributes_hash[:profile_image].present?
            end
          end

        end
      end
    end
  end
end
