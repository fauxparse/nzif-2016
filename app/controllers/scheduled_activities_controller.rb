class ScheduledActivitiesController < ApplicationController
  def show
    schedule = festival.schedules.with_activity_information.find(params[:id])
    @schedule = ScheduledActivity.new(schedule)
    render layout: false
  end
end
