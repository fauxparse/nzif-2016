class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :load_profile

  def show
  end

  def update
    if @profile.update(params)
      redirect_to profile_path, notice: "Profile updated"
    else
      render :new
    end
  end

  private

  def load_profile
    @profile = ProfileForm.new(current_user)
  end
end
