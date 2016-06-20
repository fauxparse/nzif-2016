class Admin::SchedulesController < ApplicationController
  def create
    @schedule = Schedule.create!(schedule_params.except(:position))
    @schedule.insert_at(schedule_params[:position].to_i)
    render_schedule
  end

  def edit
    render :edit, layout: false
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
      .permit(:starts_at, :ends_at, :activity_id, :position, :venue_id)
  end

  def render_schedule(status = :ok)
    respond_to do |format|
      format.html { render :edit, status: status }
      format.json do
        render json: @schedule,
         url: edit_admin_timetable_schedule_path(id: @schedule),
         status: status
      end
    end
  end
end
