class Admin::CommentsController < ApplicationController
  def create
    incident.comments.create!(comment_params) do |comment|
      comment.participant = participant
    end
    redirect_to admin_incident_path(festival, incident)
  end

  def update
    comment.update!(comment_params)
    redirect_to admin_incident_path(festival, incident)
  end

  def destroy
    comment.destroy
    redirect_to admin_incident_path(festival, incident)
  end

  private

  def incident
    @incident ||= festival.incidents.find(params[:incident_id])
  end

  def comment
    incident.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:content)
  end
end
