class Admin::FacilitatorsController < Admin::Controller
  wrap_parameters :participant, include: ParticipantForm.parameters

  def new
    @facilitator = ParticipantForm.new(nil, params)
    render layout: false
  end

  def create
    @facilitator = ParticipantForm.new(nil, params)
    if @facilitator.save
      render partial: "list", layout: false
    else
      render :new, layout: false, status: :not_acceptable
    end
  end
end
