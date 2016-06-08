FactoryGirl.define do
  factory :address do
    association :city
    addressable nil
    street { Faker::Address.street_address }
    number { Faker::Address.building_number }
    district "Bairro sem nome"
    complement { Faker::Address.secondary_address }
    zipcode { Faker::Address.zip_code }
  end

  factory :address_with_addressable, parent: :address do
    association :addressable, factory: :simple_user
  end
end
