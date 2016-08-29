class RegistrationsController < ApplicationController
  wrap_parameters :registration, include: RegistrationForm.permitted_attributes

  helper_method :registration_form

  def show
    @checklist = RegistrationChecklist.new(registration)

    respond_to do |format|
      format.html { redirect_to register_path(festival) unless registered?  }
      format.json { render json: @checklist }
    end
  end

  def new
    registration_form.step = params[:step]
    continue_with_registration
  end

  def create
    sign_in registration_form.user if registration_form.apply(params)
    Postman
      .registration_confirmation(registration_form.registration)
      .deliver_later if registration_form.complete?
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
    if registration_form.complete?
      redirect_to registration_path(festival),
        notice: t('registrations.create.completed', festival: festival)
    else
      respond_to do |format|
        format.html { render :new }
        format.json { render json: registration_form.step }
      end
    end
  end

  def registered?
    registration.present? && registration_form.complete?
  end
end
