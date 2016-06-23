FactoryGirl.define do
  factory :package_price do
    package
    amount_cents 500_00
  end
end
