class AccountsController < ApplicationController
  def show
    redirect_to register_path unless registration.present?
  end

  private

  def account
    @account ||= Account.new(registration)
  end

  helper_method :account
end
