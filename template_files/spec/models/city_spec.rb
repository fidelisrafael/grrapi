require 'rails_helper'

RSpec.describe City, type: :model do
  it 'has many address' do
    city = create(:city_with_addresses, addresses_count: 2)

    expect(city).to have_many(:addresses)
    expect(city.addresses.size).to be 2
  end

  it 'must be invalid' do
    city = build(:city, state: nil, name: nil)

    expect(city).not_to be_valid
    expect(city.errors[:state_id]).not_to be_empty
    expect(city.errors[:name]).not_to be_empty
  end
end
