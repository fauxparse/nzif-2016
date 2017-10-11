FactoryGirl.define do
  factory :incident do
    festival
    participant
    description 'Something bad happened'

    trait :anonymous do
      anonymous true
    end
  end
end
