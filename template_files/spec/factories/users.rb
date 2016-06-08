FactoryGirl.define do
  factory :user do

    trait :basic_data do
      name { Faker::Name.name }
      sequence(:email) {|n| "app_user_#{n}@gmail.com" }
      password { Faker::Internet.password(10, 20) }
      password_confirmation { password  }
    end

    factory :simple_user do
      basic_data
    end

    factory :simple_user_activated, parent: :simple_user do
      after(:build) {|user| user.activate_account! }
      after(:create) {|user| user.activate_account! }
    end

  end
end
