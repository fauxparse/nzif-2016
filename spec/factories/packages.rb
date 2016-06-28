FactoryGirl.define do
  factory :package do
    name "Basic"
    festival

    before(:create) do |package|
      package.prices.build(
        amount: 400,
        deposit: 200,
        expires_at: package.festival.start_date - 1.month
      )
      package.prices.build(
        amount: 500,
        deposit: 250,
        expires_at: package.festival.end_date + 1.day
      )
    end

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
