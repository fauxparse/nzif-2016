class ShowBookings
  attr_reader :schedule

  def initialize(schedule)
    @schedule = schedule
  end

  def show
    schedule.activity
  end

  def to_partial_path
    'shows/show'
  end

  def date
    I18n.l(schedule.starts_at.to_date, format: :full)
  end

  def times
    [
      I18n.l(schedule.starts_at, format: :short),
      I18n.l(schedule.ends_at, format: :ampm)
    ].join(' – ')
  end

  def date_and_time
    [date, times].join(', ')
  end

  def count
    schedule.selections_count
  end

  def limit
    schedule.maximum if schedule.limited?
  end

  def venue
    schedule.venue.try(:name)
  end

  def bookings
    schedule.selections
      .sort_by { |selection| selection.registration.participant.name }
      .map { |selection| Booking.new(selection) }
  end

  delegate :name, to: :show
  delegate :id, :starts_at, :ends_at, :to_param, :full?, to: :schedule

  private

  class Booking
    attr_reader :selection

    def initialize(selection)
      @selection = selection
    end

    def to_partial_path
      'shows/booking'
    end

    delegate :id, :schedule, :registration, to: :selection
    delegate :participant, to: :registration
    delegate :name, to: :participant
  end
end
