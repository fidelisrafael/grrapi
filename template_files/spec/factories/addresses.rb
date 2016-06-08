FactoryGirl.define do
  factory :address do
    addressable nil
    city { Faker::Address.city }
    street { Faker::Address.street_address }
    number { Faker::Address.building_number }
    district "Bairro sem nome"
    complement { Faker::Address.secondary_address }
    zipcode { Faker::Address.zip_code }
  end
end
