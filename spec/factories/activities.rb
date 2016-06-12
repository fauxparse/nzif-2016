FactoryGirl.define do
  factory :workshop do
    festival
    sequence(:name) { |i| "Workshop #{i}" }
    description "Lorem ipsum dolor sit amet"
  end
end
