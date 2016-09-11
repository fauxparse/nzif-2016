class WorkshopsController < ApplicationController
  def index
    @rolls = WorkshopRolls.new(participant, festival).rolls
  end
end
