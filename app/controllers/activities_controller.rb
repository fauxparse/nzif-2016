class ActivitiesController < ApplicationController
  before_action :load_activity_list

  def index
  end

  def show
    @activity = @activity_list.find(params[:id])
  end

  private

  def load_activity_list
    @activity_list = ActivityList.new(festival, type: params[:activity_type])
  end
end
