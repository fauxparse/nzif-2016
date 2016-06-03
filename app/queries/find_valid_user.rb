class FindValidUser
  def initialize(attributes)
    @name = attributes[:name]
    @email = attributes[:email]
    @password = attributes[:password]
  end

  def user
    @user ||= user_exists? && valid_password? && existing_user || nil
  end

  def participant
    return nil unless user.present?

    user.participants.detect { |participant| participant.name == @name } ||
      user.participants.first
  end

  private

  def existing_user
    @existing_user ||= User.includes(:participants).find_by(email: @email)
  end

  def user_exists?
    existing_user.present?
  end

  def valid_password?
    existing_user.valid_password?(@password)
  end
end
