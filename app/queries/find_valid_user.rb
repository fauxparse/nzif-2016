class FindValidUser
  def initialize(attributes)
    @email = attributes[:email]
    @password = attributes[:password]
  end

  def user
    user_exists? && valid_password? && existing_user || nil
  end

  private

  def existing_user
    @existing_user ||= User.find_by(email: @email)
  end

  def user_exists?
    existing_user.present?
  end

  def valid_password?
    existing_user.valid_password?(@password)
  end
end
