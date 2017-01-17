module UserConcerns
  module Address
    extend ActiveSupport::Concern

    included do
      has_one :address, as: :addressable
      accepts_nested_attributes_for :address
    end

  end
end
