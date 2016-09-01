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
    registration_form
      .on(:continue) { continue_with_registration }
      .on(:complete) { completed_registration }
      .on(:redirect) { |url| redirect_to(url) }
      .on(:error)    { render :new }
      .apply(params)
  end

  def login
    if user = FindValidUser.new(login_parameters).user
      sign_in(user)
      if registration_form.complete?
        completed_registration
      else
        continue_with_registration
      end
    else
      registration_form.step.errors.add(:email, :bad_credentials)
      render :new
    end
  end

  private

  def registration_form
    @registration_form ||=
      RegistrationForm.new(festival, participant)
        .on(:sign_in) { |user| sign_in(user) }
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

  def completed_registration
    Postman
      .registration_confirmation(registration_form.registration)
      .deliver_later
    redirect_to registration_path(festival),
      notice: I18n.t('registrations.create.completed')
  end

  def registered?
    registration.present? && registration_form.complete?
  end
end
