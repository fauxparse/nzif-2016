class IncidentsController < ApplicationController
  def new
    @incident = festival.incidents.build
  end

  def create
    @incident = festival.incidents.build(incident_params)
    @incident.participant = participant

    if @incident.save
      Postman.incident_report_notification(@incident).deliver_later
    else
      render :new
    end
  end

  private

  def incident_params
    params.require(:incident).permit(:description, :anonymous)
  end
end
