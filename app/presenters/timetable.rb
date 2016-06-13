class Timetable
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def dates
    ((festival.start_date - 1)..festival.end_date)
  end

  def times(date = dates.first)
    (18...50).map { |i| date.midnight + i * 30.minutes }
  end
end
