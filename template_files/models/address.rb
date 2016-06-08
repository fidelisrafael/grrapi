class Address < ActiveRecord::Base
  delegate :state_id, to: :city, allow_nil: true

  belongs_to :city
  belongs_to :addressable, polymorphic: true

  has_one :state, through: :city

  validates :street, :number, :zipcode, :addressable, presence: true

  validates_associated :addressable
end
