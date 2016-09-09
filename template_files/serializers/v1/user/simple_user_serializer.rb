module Serializers
  module V1
    class SimpleUserSerializer < ActiveModel::Serializer

      root false

      attributes :id, :profile_type, :profile_image_url, :profile_images,
                  :first_name, :last_name, :name, :username, :created_at

    end
  end
end
