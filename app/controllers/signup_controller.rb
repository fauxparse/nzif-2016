class SignupController < Devise::RegistrationsController
  after_action :create_participant, only: :create

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def create_participant
    resource.participants.create(name: resource.name) if resource.persisted?
  end
end
