FactoryGirl.define do
  factory :payment do
    registration
    amount_cents 10000

    factory :internet_banking_payment do
      payment_type 'internet_banking'
    end
  end
end
