class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
  end

  def update
    if participant_form.save
      redirect_to profile_path, notice: "Profile updated"
    else
      render :show
    end
  end

  private

  def participant_form
    @form ||= ParticipantForm.new(participant, params)
  end

  helper_method :participant_form
end
