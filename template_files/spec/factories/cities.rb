FactoryGirl.define do
  factory :city_sp do
    association :state, factory: :state_sp
    name "São Paulo"
  end

  factory :city do
    association :state, factory: :state
    name { Faker::Address.city }
  end


  factory :city_with_addresses, parent: :city do
    transient do
      addresses_count 5
    end

    after(:create) do |city, evaluator|
      create_list(:address, evaluator.addresses_count, city: city, addressable: build(:simple_user))
    end
  end
end
