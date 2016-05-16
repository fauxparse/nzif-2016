FactoryGirl.define do
  factory :participant do
    sequence(:name) { |n| "Participant #{n}" }
    sequence(:email) { |n| "participant#{n}@example.com" }

    trait :with_associated_user do
      email nil
      user
    end
  end
end
