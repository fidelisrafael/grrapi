FactoryGirl.define do
  factory :origin do
    ip { Faker::Internet.ip_v4_address }
    provider 'faker'
    user_agent "Mozilla/5.0 (X11; Linux i686 (x86_64)) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/43.0.2357.81 Safari/537.36"
    locale { I18n.available_locales.sample }
  end
end
