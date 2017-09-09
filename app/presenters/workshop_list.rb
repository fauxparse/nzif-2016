class WorkshopList
  attr_reader :festival

  def initialize(festival)
    @festival = festival
  end

  def to_ary
    workshops.map { |workshop| ShowBookings.new(workshop) }
  end

  def title
    'Workshop bookings'
  end

  alias :to_a :to_ary

  def workshops
    festival.schedules.includes(:activity, :venue)
      .references(:activity)
      .where('activities.type' => 'Workshop')
      .order(:starts_at)
  end
end
