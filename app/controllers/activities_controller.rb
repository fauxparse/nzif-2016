class ActivitiesController < ApplicationController
  before_action :load_activity_list

  def index
  end

  def show
    @activity = ActivityDetails.new(@activity_list.find(params[:id]), registration)
  end

  private

  def load_activity_list
    @activity_list = ActivityList.new(festival, type: params[:activity_type])
  end
end
