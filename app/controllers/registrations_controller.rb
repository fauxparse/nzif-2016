class RegistrationsController < ApplicationController
  wrap_parameters :registration, include: RegistrationForm.permitted_attributes

  helper_method :registration_form

  def show
    redirect_to registration_path(festival) unless registration.present?
  end

  def new
  end

  def create
    registration_form.save!
    ParticipantMailer
      .registration_email(registration_form.registration)
      .deliver_later

    sign_in registration_form.user
    redirect_to registration_path(festival)
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
