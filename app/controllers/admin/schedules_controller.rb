class Admin::SchedulesController < ApplicationController
  def create
    @schedule = Schedule.create!(schedule_params.except(:position))
    @schedule.insert_at(schedule_params[:position].to_i)
    render_schedule
  end

  def update
    schedule.remove_from_list
    schedule.update!(schedule_params.except(:position))
    schedule.insert_at(schedule_params[:position].to_i) \
      if schedule_params[:position].present?
    render_schedule
  end

  def destroy
    schedule.destroy
  end

  private

  def schedule
    @schedule ||= Schedule.find(params[:id])
  end

  def schedule_params
    @schedule_params ||= params
      .require(:schedule)
      .permit(:starts_at, :ends_at, :activity_id, :position)
  end

  def render_schedule
    render json: @schedule,
      url: edit_admin_timetable_schedule_path(id: @schedule)
  end
end
