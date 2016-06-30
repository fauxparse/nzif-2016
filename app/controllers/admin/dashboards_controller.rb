class Admin::DashboardsController < Admin::Controller
  def show
    redirect_to admin_festival_path(festival)
  end
end
