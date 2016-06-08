require 'rails_helper'

RSpec.describe State, type: :model do
  it 'has many cities' do
    state = create(:state_with_cities, cities_count: 2)

    expect(state).to have_many(:cities)
    expect(state.cities.size).to be 2
  end

  it 'has many addresses through city' do
    state = create(:state)
    city = create(:city_with_addresses, state: state, addresses_count: 2)

    expect(state).to have_many(:addresses)

    expect(state.addresses.size).to be 2
    expect(state.cities.size).to be 1
  end

  it 'must be invalid' do
    state = build(:state, acronym: nil, name: nil)

    expect(state).not_to be_valid
    expect(state.errors[:acronym]).not_to be_empty
    expect(state.errors[:name]).not_to be_empty
  end
end
