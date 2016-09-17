class BoxOffice::TicketsController < BoxOffice::Controller
  def show
    redirect_to edit_box_office_show_ticket_path
  end

  def edit
  end

  def update
    UpdateBooking.new(selection, params)
      .on(:success) { |selection| redirect_to box_office_show_path(festival, selection.schedule_id), notice: 'Booking updated' }
      .on(:failure) { render :edit }
      .call
  end

  def destroy
    selection.destroy
    redirect_to box_office_show_path(festival, selection.schedule_id)
  end

  private

  def selection
    @selection ||= schedule.selections.find(params[:id])
  end

  def ticket
    @ticket ||= Ticket.new(selection)
  end

  helper_method :ticket

  def schedule
    @schedule ||= festival.schedules.find(params[:show_id])
  end

  def activity
    @activity ||= ShowBookings.new(schedule)
  end

  helper_method :activity
end
