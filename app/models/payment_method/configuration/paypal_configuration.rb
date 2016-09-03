module PaymentMethod::Configuration
  class PaypalConfiguration < Base
    configure_with :merchant_email

    validates :merchant_email,
      format: { with: /\A[^@\s]+@[^@\s]+\z/, allow_blank: true }

    def usable?
      super && merchant_email?
    end

    def paypal_host
      ENV['PAYPAL_HOST']
    end
  end
end
