class CalendarsController < ApplicationController
  def show
    respond_to do |format|
      format.ics do
        render plain: calendar.to_ics, content_type: 'text/calendar'
      end
    end
  end

  private

  def calendar
    Calendar.new(Registration.find_by_pleasant_lawyer(params[:id]))
  end
end
