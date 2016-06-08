class Admin::FestivalsController < Admin::Controller
  def show
  end

  def edit
  end

  def update
    if festival.update(festival_params)
      redirect_to edit_admin_festival_path(festival)
    else
      render :edit
    end
  end

  private

  def festival_params
    params.require(:festival).permit(:start_date, :end_date)
  end
end
