FactoryGirl.define do
  factory :authorization do |f|
    association :user, factory: :simple_user_activated
    provider { Authorization::PROVIDERS.sample }
  end
end
