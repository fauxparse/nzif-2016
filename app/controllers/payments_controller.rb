class PaymentsController < ApplicationController
  before_action :ensure_registered, except: :paypal
  skip_before_action :verify_authenticity_token, \
    if: :processing_external_payment?

  def show
    if params[:year]
      @payment = registration.payments.find_by!(token: params[:id])
      redirect_to account_path(registration.festival)
    else
      begin
        registration = payment.registration
        redirect_to account_path(registration.festival)
      rescue ActiveRecord::RecordNotFound => e
        redirect_to root_path
      end
    end
  end

  def create
    CreatePayment.new(registration, payment_params)
      .on(:success) { |payment| redirect_to(account_payment_path(festival, payment)) }
      .on(:redirect) { |payment, url| redirect_to(url) }
      .call
  end

  def paypal
    payment.payment_method.process!(payment, params.permit!)

    head :ok
  end

  private

  def payment_params
    params.require(:payment).permit(:amount, :payment_type)
  end

  def processing_external_payment?
    request.post? && %w(show paypal).include?(action_name)
  end

  def payment
    @payment ||= Payment.includes(:registration).find_by!(token: params[:id])
  end
end
