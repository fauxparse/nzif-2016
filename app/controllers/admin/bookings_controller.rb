module Admin
  class BookingsController < Controller
    def edit
    end

    def update
      booking.update!(booking_params)
      redirect_to edit_admin_booking_path(festival, booking)
    end

    def destroy
      booking.destroy
      redirect_to admin_reports_path(festival)
    end

    private

    def booking
      festival.selections.find(params[:id])
    end

    helper_method :booking

    def ticket
      @ticket ||= Ticket.new(booking)
    end

    helper_method :ticket

    def booking_params
      params.require(:selection).permit(:schedule_id)
    end
  end
end
