class ProfileForm
  def initialize(user)
    @user = user
  end

  def update(params)
    participant.update(sanitize(params))
  end

  def to_model
    participant
  end

  delegate :name, :email, :bio, :avatar, :errors, to: :participant

  private

  def participant
    participant = @user.participants.first || @user.participants.build
  end

  def sanitize(params)
    params.require(:profile).permit(:name, :email, :bio, :avatar)
  end
end
