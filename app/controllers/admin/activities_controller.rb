class Admin::ActivitiesController < Admin::Controller
  wrap_parameters :activity, include: ActivityForm.parameters

  def index
    @activity_list = ActivityList.new(festival, type: params[:type] || "workshops")
  end

  def show
  end

  def new
  end

  def create
    if activity_form.save
      redirect_to admin_activity_path(festival, activity)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if activity_form.save
      redirect_to admin_activity_path(festival, activity)
    else
      render :edit
    end
  end

  private

  def activity
    @activity ||= begin
      if params[:id].present?
        festival.activities.find_by(slug: params[:id])
      else
        Activity.type(params[:type]).new(festival: festival)
      end
    end
  end

  def activity_form
    @activity_form ||= ActivityForm.new(activity, params)
  end

  helper_method :activity, :activity_form
end
