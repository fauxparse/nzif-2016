module Admin::PaymentConfigurationHelper
  def account_number_format
    PaymentMethod::Configuration::InternetBankingConfiguration::ACCOUNT_NUMBER_FORMAT
      .gsub(/\[0-9\]\{(\d,)?(\d)\}/) { 'X' * $2.to_i }
  end
end
