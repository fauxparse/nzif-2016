FactoryGirl.define do
  factory :voucher do
    festival
    participant
    admin
    amount "100"
    reason "Thank you"
  end
end
