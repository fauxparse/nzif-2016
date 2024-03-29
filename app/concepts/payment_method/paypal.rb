class PaymentMethod::Paypal < PaymentMethod::Base
  include Rails.application.routes.url_helpers

  def created
    publish(:redirect, paypal_url)
  end

  def process!(payment, params)
    case params[:payment_status]
    when 'Completed', 'Processed'
      complete_payment(params)
    when 'Denied', 'Failed'
      fail_payment(params)
    when 'Expired', 'Reversed', 'Voided'
      cancel_payment(params)
    when 'Refunded'
      refund_payment(params)
    end
  end

  private

  def paypal_url
    registration = payment.registration
    festival = registration.festival

    values = {
      business: configuration.merchant_email,
      cmd: "_xclick",
      upload: 1,
      return: paypal_return_url(payment),
      notify_url: paypal_callback_url(payment),
      invoice: payment.to_param,
      amount: payment.total,
      currency_code: payment.total.currency.iso_code,
      item_name: festival.name
    }
    "#{configuration.paypal_host}/cgi-bin/webscr?" + values.to_query
  end

  def complete_payment(params)
    update_payment(:approved, params)
  end

  def fail_payment(params)
    update_payment(:failed, params)
  end

  def cancel_payment(params)
    update_payment(:cancelled, params)
  end

  def refund_payment(params)
    update_payment(:refunded, params)
  end

  def update_payment(status, params)
    paid = Money.from_amount(params[:mc_gross].to_d, params[:mc_currency])
    UpdatePayment.new(
      payment,
      status,
      transaction_reference: params[:txn_id],
      transaction_data: sanitize_transaction_data(params.to_h),
    ).call
  end

  def sanitize_transaction_data(data)
    if data[:charset]
      charset = data[:charset]
      data.to_a.each.with_object({}) do |(key, value), hash|
        hash[key] = value.force_encoding('windows-1252').encode('utf-8')
      end
    else
      data
    end
  end
end
