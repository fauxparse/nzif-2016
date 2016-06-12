FactoryGirl.define do
  factory :workshop do
    festival
    sequence(:name) { |i| "Workshop #{i}" }
    description "Lorem ipsum dolor sit amet"

    trait :facilitated do
      transient { facilitators_count 2 }
      after(:create) do |activity, evaluator|
        create_list(
          :facilitator,
          evaluator.facilitators_count,
          activity: activity
        )
      end
    end

    factory :activity
  end
end
