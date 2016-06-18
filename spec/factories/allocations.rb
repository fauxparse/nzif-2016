FactoryGirl.define do
  factory :allocation do
    package
    activity_type Workshop
    maximum 3
  end
end
