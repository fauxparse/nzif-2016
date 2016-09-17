class BoxOffice::Controller < ApplicationController
  before_action :require_box_office_access

  private

  def require_box_office_access
    render_error(:forbidden) unless signed_in? &&
      (current_user.admin? || current_user.box_office?)
  end
end
