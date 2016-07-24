class PaymentMethod::Paypal < PaymentMethod
  include Rails.application.routes.url_helpers

  def created(payment)
    publish(:redirect, paypal_url(payment))
  end

  def process!(payment, params)
    case params[:payment_status]
    when 'Completed', 'Processed'
      complete_payment(payment, params)
    when 'Denied', 'Failed'
      fail_payment(payment, params)
    when 'Expired', 'Reversed', 'Voided'
      cancel_payment(payment, params)
    when 'Refunded'
      refund_payment(payment, params)
    end
  end

  private

  def paypal_url(payment)
    registration = payment.registration
    festival = registration.festival

    values = {
      business: ENV['MERCHANT_EMAIL'],
      cmd: "_xclick",
      upload: 1,
      return: paypal_return_url(payment),
      notify_url: paypal_callback_url(payment),
      invoice: payment.to_param,
      amount: payment.amount,
      currency_code: payment.amount.currency.iso_code,
      item_name: festival.name
    }
    "#{ENV['PAYPAL_HOST']}/cgi-bin/webscr?" + values.to_query
  end

  def complete_payment(payment, params)
    update_payment(payment, :approved, params)
  end

  def fail_payment(payment, params)
    update_payment(payment, :failed, params)
  end

  def cancel_payment(payment, params)
    update_payment(payment, :cancelled, params)
  end

  def refund_payment(payment, params)
    update_payment(payment, :refunded, params)
  end

  def update_payment(payment, status, params)
    payment.update!(
      amount: Money.from_amount(params[:mc_gross].to_d, params[:mc_currency]),
      transaction_reference: params[:txn_id],
      transaction_data: params.to_h,
      status: status
    )
  end
end
