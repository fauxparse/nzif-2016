class ParticipantForm
  include ActiveModel::Validations

  attr_reader :participant
  delegate :name, :id, :email, :name=, :bio, :bio=, :avatar, :avatar=,
    :to_param, to: :participant
  delegate :admin, :admin=, to: :user

  def initialize(participant = nil, params = nil)
    @participant = participant || Participant.new
    apply(sanitize(params))
  end

  def user
    participant.user || participant.build_user
  end

  def valid?
    errors.clear
    [user, participant].select(&:changed?).each do |model|
      model.errors.each do |attr, msg|
        errors.add(attr, msg) unless errors[attr].include?(msg)
      end unless model.valid?
    end
    errors.empty?
  end

  def save
    return false unless valid?
    user.save if user.changed?
    participant.save
  end

  def email=(value)
    if user.persisted?
      user.email = value
    else
      participant.email = value
    end
  end

  def to_model
    participant
  end

  def self.parameters
    %i[name email admin bio avatar]
  end

  private

  def sanitize(params)
    return {} if params.blank? || params[:participant].blank?
    params.require(:participant)
      .permit(*self.class.parameters)
  end

  def apply(parameters)
    parameters.each { |attr, value| send(:"#{attr}=", value) }
    if user.new_record? && user.changed?
      user.name = participant.name
      user.email = participant.email
      user.password = user.password_confirmation = random_password
      participant.email = nil
    end
  end

  def random_password
    Devise.friendly_token.first(8)
  end
end
