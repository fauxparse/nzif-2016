class RegistrationsController < ApplicationController
  wrap_parameters :registration, include: RegistrationForm.permitted_attributes

  helper_method :registration_form

  def show
    redirect_to registration_path(festival) unless registration.present?
  end

  def new
    registration_form.step = params[:step]
  end

  def create
    registration_form.save!
    sign_in registration_form.user

    if registration_form.complete?
      ParticipantMailer
        .registration_email(registration_form.registration)
        .deliver_later

      redirect_to registration_path(festival)
    else
      render :new
    end
  rescue ActiveModel::ValidationError
    render :new
  end

  private

  def registration
    @registration ||= festival.registrations.find_by!(participant: participant)
  end

  def registration_form
    @registration_form ||= RegistrationForm.new(festival, participant, params)
  end
end
