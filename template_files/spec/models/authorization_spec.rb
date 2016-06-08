require 'rails_helper'

RSpec.describe Authorization, type: :model do
  before(:each) do
    @authorization = create(:authorization)
  end

  it 'is valid' do
    expect(@authorization).to be_valid
  end

  it 'has valid provider' do
    expect(@authorization.errors[:provider]).to eq([])
  end

  it 'must normalize provider name' do
    provider = Authorization::PROVIDERS.keys.first.to_s

    @authorization.provider = provider.upcase

    expect(@authorization).to be_valid
    expect(@authorization.provider).to eq(provider)
  end

  it 'belongs to user' do
    expect(@authorization.user).not_to be_nil
  end

  it 'has not expired' do
    expect(@authorization.expired?).to be false
    expect(@authorization.valid_access?).to be true
  end

  it 'has expired' do
    @authorization.expires_at = Time.zone.now - 1.minute

    expect(@authorization.expired?).to be true
    expect(@authorization.valid_access?).to be false
  end

  it 'must have invalid provider' do
    @authorization.provider = SecureRandom.hex # make sure this is a unique provider

    expect(@authorization).to_not be_valid
    expect(@authorization.errors[:provider]).to_not eq([])
  end

  it 'must contains a 32 length token' do
    expect(@authorization.token.size).to be 32
  end

  it 'must be eligible for  expiration date update' do
    eligible_expiration_date = Authorization::EXPIRATION_TIME_LEFT_TO_UPDATE
    @authorization.expires_at = Time.zone.now + eligible_expiration_date

    expect(@authorization.eligible_for_expiration_update?).to be true
  end

  it 'must not be eligible for expiration date update' do
    not_eligible_expiration_date = (Authorization::EXPIRATION_TIME_LEFT_TO_UPDATE * 2)

    @authorization.expires_at = Time.zone.now + not_eligible_expiration_date

    expect(@authorization.eligible_for_expiration_update?).to be false
  end

  it 'must be forced to be eligible for expiration date update' do
    expect(@authorization.eligible_for_expiration_update?(true)).to be true
  end

  it 'must update expiration date correctly' do
    last_expires_at = @authorization.expires_at
    expiration_date = @authorization.send(:expiration_date_from_now)

    @authorization.update_token_expires_at(true)

    expect(@authorization.expires_at).to be > last_expires_at
    expect(@authorization.expires_at).to be > expiration_date
  end

  it 'must be valid with new providers' do
    Authorization::PROVIDERS[:tv_app] = 'TvApp'

    @authorization = build(:authorization, provider: :tv_app)

    @authorization.class_eval do
      _validate_callbacks.clear
      validates :provider, inclusion: Authorization::PROVIDERS.keys.map(&:to_s)
    end

    expect(@authorization).to be_valid
    expect(@authorization.errors[:provider]).to eq([])
  end

end
