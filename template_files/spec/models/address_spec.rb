require 'rails_helper'

RSpec.describe Address, type: :model do
  it 'must belongs to user' do
    address = create(:address_with_addressable)

    expect(address.addressable).to be_a(User)
    expect(address).to be_valid
  end

  it 'must belongs to addressable' do
    address = build(:address)

    expect(address.addressable).to be_nil

    expect(address).not_to be_valid

    address.addressable = build(:simple_user)

    expect(address.addressable).to be_a(User)
    expect(address).to be_valid
  end

  it 'must delegate state attributes to city association' do
    address = build(:address)

    expect(address.state_id).to eq(address.city.state_id)
    expect(address.state.acronym).to eq(address.city.state.acronym)
  end

  it 'must validate basic attributes presence' do
    [:street, :number, :zipcode].each do |attr|
      address = build(:address, attr => nil)

      expect(address).not_to be_valid
      expect(address.errors[attr]).not_to be_empty
    end
  end

end
