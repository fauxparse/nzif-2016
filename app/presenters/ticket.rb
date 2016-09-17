class Ticket
  def initialize(selection)
    @selection = selection
  end

  def to_model
    selection
  end

  def available_schedules(festival)
    ShowList.new(festival)
      .to_ary
      .group_by { |show| show.starts_at.to_date }
  end

  private

  attr_reader :selection

  delegate :id, :to_param, :errors, :schedule_id, :schedule, :registration, to: :selection
  delegate :participant, to: :registration
  delegate :name, :email, to: :participant
end
