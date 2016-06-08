FactoryGirl.define do
  factory :state_sp do
    name "São Paulo"
    acronym "SP"
  end

  factory :state do
    name { Faker::Address.state }
    acronym { Faker::Address.state_abbr }
  end
end
