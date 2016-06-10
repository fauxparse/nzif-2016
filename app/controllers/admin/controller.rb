class Admin::Controller < ApplicationController
  before_action :require_admin

  private

  def require_admin
    render_error(:forbidden) unless signed_in? && current_user.admin?
  end

  def render_error(code)
    render "errors/#{code}", status: code, layout: "errors"
  end
end
