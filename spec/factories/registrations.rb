FactoryGirl.define do
  factory :registration do
    participant
    festival
    package { FactoryGirl.create(:package, :with_limits, festival: festival) }
  end
end
