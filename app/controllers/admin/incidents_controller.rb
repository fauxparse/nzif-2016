module Admin
  class IncidentsController < Controller
    def index
      @incidents = IncidentList.new(festival: festival, status: status)
    end

    def show
      redirect_to admin_incidents_path(festival) unless incident.present?
    end

    def close
      create_marker_comment(:closed)
      incident.closed!
      redirect_to admin_incident_path(festival, incident)
    end

    def reopen
      create_marker_comment(:reopened)
      incident.open!
      redirect_to admin_incident_path(festival, incident)
    end

    private

    def status
      params[:status] || :open
    end

    def incident
      @incident ||= IncidentDetails.new(
        festival.incidents.includes(:participant).find(params[:id])
      )
    end

    helper_method :incident

    def create_marker_comment(content)
      incident.comments.create!(
        content: I18n.t(content, scope: 'admin.incidents'),
        participant: participant
      )
    end
  end
end
