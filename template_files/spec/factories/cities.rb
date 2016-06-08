FactoryGirl.define do
  factory :city_sp do
    association :state, factory: :state_sp
    name "São Paulo"
  end

  factory :city do
    association :state, factory: :state
    name { Faker::Address.city }
  end
end
