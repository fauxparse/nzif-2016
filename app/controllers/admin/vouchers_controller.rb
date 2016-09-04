class Admin::VouchersController < Admin::Controller
  before_action :load_vouchers
  before_action :load_voucher, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @voucher = @vouchers.scope.build
  end

  def create
    @voucher = @vouchers.scope.build(voucher_params)
    @voucher.admin = current_user
    if @voucher.save
      redirect_to admin_vouchers_path, notice: I18n.t('admin.vouchers.created')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @voucher.update(voucher_params)
      redirect_to admin_vouchers_path, notice: I18n.t('admin.vouchers.updated')
    else
      render :edit
    end
  end

  def destroy
    @voucher.destroy
    redirect_to admin_vouchers_path, notice: I18n.t('admin.vouchers.destroyed')
  end

  private

  def load_vouchers
    @vouchers = VoucherList.new(festival)
  end

  def load_voucher
    @voucher = @vouchers.find(params[:id])
  end

  def voucher_params
    params.require(:voucher).permit(:participant_id, :amount, :reason)
  end
end
