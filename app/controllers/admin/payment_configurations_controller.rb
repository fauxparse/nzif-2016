class Admin::PaymentConfigurationsController < Admin::Controller
  def edit
  end

  def update
    if payment_configuration.save
      redirect_to admin_payments_settings_path
    else
      render :edit_configuration
    end
  end

  private

  def payment_configuration
    @payment_configuration ||= PaymentConfigurationForm.new(festival, params)
  end

  helper_method :payment_configuration
end

