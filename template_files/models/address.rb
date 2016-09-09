class Address < ActiveRecord::Base
  attr_accessor :skip_addressable_validation

  delegate :state_id, to: :city, allow_nil: true

  belongs_to :city
  belongs_to :addressable, polymorphic: true

  has_one :state, through: :city

  validates :city, :street, :number, :zipcode, presence: true
  validates :addressable, presence: true, if: -> { skip_addressable_validation.blank? }

  validates_associated :addressable

  before_save :normalize_zipcode
  before_validation :normalize_zipcode

  def self.normalize_zipcode(zipcode)
    zipcode.to_s.gsub(/[^\d+]/, '')
  end

  def normalize_zipcode
    self.zipcode = self.class.normalize_zipcode(self.zipcode)
  end
end
