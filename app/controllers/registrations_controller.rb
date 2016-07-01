class RegistrationsController < ApplicationController
  wrap_parameters :registration, include: RegistrationForm.permitted_attributes

  helper_method :registration_form

  def show
    redirect_to register_path(festival) unless registered?

    @checklist = RegistrationChecklist.new(registration)
  end

  def new
    registration_form.step = params[:step]
    render_next_registration_step
  end

  def create
    sign_in registration_form.user if registration_form.apply(params)
    continue_with_registration

  rescue ActiveModel::ValidationError
    render :new
  end

  def login
    if user = FindValidUser.new(login_parameters).user
      sign_in(user)
      continue_with_registration
    else
      registration_form.step.errors.add(:email, :bad_credentials)
      render :new
    end
  end

  private

  def registration_form
    @registration_form ||= RegistrationForm.new(festival, participant)
  end

  def login_parameters
    params.require(:registration).permit(:email, :password)
  end

  def logging_in?
    action_name == "login"
  end
  helper_method :logging_in?

  def continue_with_registration
    ParticipantMailer
      .registration_email(registration_form.registration)
      .deliver_later if registration_form.complete?
    render_next_registration_step
  end

  def render_next_registration_step
    if registration_form.complete?
      redirect_to registration_path(festival)
    else
      render :new
    end
  end

  def registered?
    registration.present? && registration_form.complete?
  end
end
