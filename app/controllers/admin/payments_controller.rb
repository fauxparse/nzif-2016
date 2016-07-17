class Admin::PaymentsController < Admin::Controller
  def index
    @payments = PaymentList.new(festival, params)
  end

  def approve
    payment.approve!
    head :ok
  end

  def decline
    payment.decline!
    head :ok
  end

  def destroy
    payment.cancel!
    head :ok
  end

  private

  def payment
    @payment ||= festival.payments.find_by!(token: params[:id])
  end
end
