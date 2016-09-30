class WorkshopsController < ApplicationController
  before_action :require_participant

  def index
    @rolls = WorkshopRolls.new(participant, festival).rolls
  end

  private

  def require_participant
    redirect_to festival_path(festival) unless participant.present?
  end
end
