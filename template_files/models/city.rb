class City < ActiveRecord::Base
  has_many :addresses

  belongs_to :state

  validates :state_id, :name, presence: true
end
