class RegistrationsController < ApplicationController
  helper_method :registration_form

  def show
    redirect_to registration_path(festival) unless registration.present?
  end

  def new
  end

  def create
    if registration_form.save
      redirect_to registration_path(festival)
    else
      render :new
    end
  end

  private

  def registration
    @registration ||= festival.registrations.find_by!(participant: participant)
  end

  def registration_form
    @registration_form ||= RegistrationForm.new(festival, participant, params)
  end
end
