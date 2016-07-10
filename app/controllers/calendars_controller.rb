class CalendarsController < ApplicationController
  def show
    respond_to do |format|
      format.ics do
        render text: calendar.to_ics
      end
    end
  end

  private

  def calendar
    Calendar.new(Registration.find_by_pleasant_lawyer(params[:id]))
  end
end
