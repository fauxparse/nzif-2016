FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password "p4$$w0rd!"
    password_confirmation "p4$$w0rd!"
  end
end
