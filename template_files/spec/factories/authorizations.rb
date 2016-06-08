FactoryGirl.define do
  factory :authorization do |f|
    association :user, factory: :simple_user
    provider { Authorization::PROVIDERS.sample }
  end
end
