FactoryGirl.define do
  factory :package do
    name "Basic"
    festival

    trait :with_limits do
      after(:create) do |package|
        package.allocations.create(activity_type: Workshop, maximum: 3)
        package.allocations.create(activity_type: Show, maximum: 3)
        package.allocations.create(activity_type: SocialEvent, maximum: nil)
        package.allocations.create(activity_type: Discussion, maximum: 0)
      end
    end
  end
end
