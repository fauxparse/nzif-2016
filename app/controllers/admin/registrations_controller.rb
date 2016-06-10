class Admin::RegistrationsController < Admin::Controller
  def show
  end

  def new
  end

  def create
    registration.attributes = registration_params
    if registration.save
      redirect_to \
        admin_festival_participant_registration_path(festival, participant)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if registration.update!(registration_params)
      redirect_to \
        admin_festival_participant_registration_path(festival, participant)
    else
      render :edit
    end
  end

  private

  def registration_params
    params.require(:registration).permit(:package_id)
  end

  def participant
    @participant ||= Participant.find(params[:festival_participant_id])
  end

  def registration
    @registration ||= festival.registrations
      .find_or_initialize_by(participant: participant)
  end

  helper_method :registration
end
