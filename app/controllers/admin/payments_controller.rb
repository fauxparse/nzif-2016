class Admin::PaymentsController < Admin::Controller
  def index
    @payments = PaymentList.new(festival, params)
  end

  def approve
    update_payment(:approved)
    head :ok
  end

  def decline
    update_payment(:failed)
    head :ok
  end

  def destroy
    update_payment(:cancelled)
    head :ok
  end

  private

  def payment
    @payment ||= festival.payments.find_by!(token: params[:id])
  end

  def update_payment(status)
    UpdatePayment.new(payment, status).call
  end
end
