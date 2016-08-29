class Admin::SchedulesController < ApplicationController
  def new
    @schedule = Schedule.new(schedule_params)
    render_schedule
  end

  def create
    @schedule = Schedule.create!(schedule_params)
    render json: schedule, serializer: TimetableScheduleSerializer
  end

  def edit
    render_schedule
  end

  def update
    schedule.remove_from_list if schedule_params[:position].present?
    if schedule.update(schedule_params.except(:position))
      schedule.insert_at(schedule_params[:position].to_i) \
        if schedule_params[:position].present?
      render_schedule
    else
      Schedule.find(schedule.id).insert_at(schedule.position)
      render_schedule(:not_acceptable)
    end
  end

  def destroy
    schedule.destroy
  end

  private

  def schedule
    @schedule ||= Schedule.find(params[:id])
  end

  helper_method :schedule

  def schedule_params
    @schedule_params ||= params
      .require(:schedule)
      .permit(
        :starts_at,
        :ends_at,
        :activity_id,
        :position,
        :venue_id,
        :maximum
      )
  end

  def render_schedule(status = :ok)
    respond_to do |format|
      format.html do
        template = schedule.id.blank? ? :new : :edit
        render template, layout: false, status: status
      end
      format.json do
        render json: @schedule,
          serializer: TimetableScheduleSerializer,
          status: status
      end
    end
  end
end
