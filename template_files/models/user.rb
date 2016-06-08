class User < ActiveRecord::Base
  has_secure_password

  has_one :address, as: :addressable

  validates :name, :email, presence: true

  accepts_nested_attributes_for :address
end
