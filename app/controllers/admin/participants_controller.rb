class Admin::ParticipantsController < Admin::Controller
  wrap_parameters :participant, include: ParticipantForm.parameters

  def index
    @participants = ParticipantList.new(
      festival: festival,
      show_all: params[:year].blank?
    )
  end

  def new
    @participant = ParticipantForm.new
  end

  def create
    @participant = ParticipantForm.new(nil, params)
    if @participant.save
      redirect_to admin_participants_path
    else
      render :new
    end
  end

  def edit
    @participant = ParticipantForm.new(Participant.find(params[:id]))
  end

  def update
    @participant = ParticipantForm.new(Participant.find(params[:id]), params)
    if @participant.save
      redirect_to admin_participants_path
    else
      render :edit
    end
  end
end
