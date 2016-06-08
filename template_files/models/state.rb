class State < ActiveRecord::Base
  has_many :cities

  has_many :addresses, through: :cities

  validates :name, :acronym, presence: true, uniqueness: true

  def uf
    self.acronym
  end
end
