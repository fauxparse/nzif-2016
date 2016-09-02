module PaymentsHelpers
  def bank_account_name
    internet_banking_configuration.account_name
  end

  def bank_account_number
    internet_banking_configuration.account_number
  end

  private

  def internet_banking_configuration
    @internet_banking_configuration ||= PaymentMethod::Configuration::InternetBankingConfiguration
      .find_by(festival: festival)
  end
end

World(PaymentsHelpers)
