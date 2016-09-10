class UpdatePayment
  attr_reader :payment, :params

  def initialize(payment, status, params = {})
    @payment = payment
    @params = params.reverse_merge(status: status)
  end

  def call
    payment.update!(params)
    send_receipt
    CompleteRegistration.new(payment.registration).call if payment.approved?
  end

  private

  def send_receipt
    Postman.receipt(payment).deliver_later if payment.approved?
  end
end
