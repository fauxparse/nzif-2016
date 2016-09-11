class ActivitiesController < ApplicationController
  def index
    @activity_list = ActivityList.new(
      festival,
      type: params[:activity_type],
      sort_by: :time
    )
  end

  def show
    @activity_list = ActivityList.new(
      festival,
      type: params[:activity_type]
    )
    @activity = ActivityDetails.new(@activity_list.find(params[:id]), registration)
  end
end
