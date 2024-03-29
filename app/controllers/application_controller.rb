class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :festival, :registration

  private

  def festival
    @festival ||=
      if params[:year]
        festival_scope.find_by!(year: params[:year])
      else
        festival_scope.most_recent_first.first
      end
  end

  def festival_scope
    Festival
  end

  def participant
    @participant ||= current_user && (
      current_user.participants.first ||
      current_user.participants.build
    )
  end

  helper_method :participant

  def registration
    @registration ||= festival.registrations.find_by(participant: participant)
  end

  def ensure_registered
    redirect_to register_path(festival) unless registration.present?
  end

  def render_error(code)
    render "errors/#{code}", status: code, layout: "errors"
  end
end
