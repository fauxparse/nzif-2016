FactoryGirl.define do
  factory :internet_banking_configuration, class: "PaymentMethod::Configuration::InternetBankingConfiguration" do
    account_name "Griphook"
    account_number "01-2345-6789012-34"
  end
end
