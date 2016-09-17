class ShowList
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def to_ary
    shows.map { |show| ShowBookings.new(show) }
  end

  alias :to_a :to_ary

  def shows
    festival.schedules.includes(:activity, :venue)
      .references(:activity)
      .where('activities.type' => 'Show')
      .order(:starts_at)
  end
end
