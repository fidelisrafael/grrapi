FactoryGirl.define do
  factory :state_sp do
    name "São Paulo"
    acronym "SP"
  end

  factory :state do
    name { Faker::Address.state }
    acronym { Faker::Address.state_abbr }
  end

  factory :state_with_cities, parent: :state do
    transient do
      cities_count 5
    end

    after(:create) do |state, evaluator|
      create_list(:city, evaluator.cities_count, state: state)
    end
  end
end
