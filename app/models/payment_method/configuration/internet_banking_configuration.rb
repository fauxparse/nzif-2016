module PaymentMethod::Configuration
  class InternetBankingConfiguration < Base
    configure_with :account_name
    configure_with :account_number

    ACCOUNT_NUMBER_FORMAT = '[0-9]{2}-[0-9]{4}-[0-9]{7}-[0-9]{2,3}'

    validates :account_number,
      format: { with: /\A#{ACCOUNT_NUMBER_FORMAT}\z/, allow_blank: true }

    def usable?
      super && account_name? && account_number?
    end
  end
end
