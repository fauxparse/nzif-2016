module Admin
  class BookingsController < Controller
    def new
      @booking = Selection.new(registration_id: params[:registration_id])
    end

    def create
      @booking = Selection.new(booking_params)
      if @booking.save
        redirect_to admin_participant_registration_path(festival, @booking.registration.participant)
      else
        render :new
      end
    end

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
      @booking ||= festival.selections.find(params[:id])
    end

    helper_method :booking

    def ticket
      @ticket ||= Ticket.new(booking)
    end

    helper_method :ticket

    def booking_params
      params.require(:selection).permit(:registration_id, :schedule_id)
    end
  end
end
