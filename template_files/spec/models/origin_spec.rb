require 'rails_helper'

RSpec.describe Origin, type: :model do
  it 'must have valid authorization provider' do
    origin = build(:origin)
    origin.originable = create(:simple_user)

    expect(origin).to be_valid
    expect(origin).to belong_to(:originable)

    origin.provider = SecureRandom.hex # make sure this is a invalid provider

    expect(origin).not_to be_valid
    expect(origin.errors[:provider]).not_to eq([])
  end
end
