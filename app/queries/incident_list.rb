class IncidentList
  attr_reader :festival, :status

  def initialize(festival: nil, status: :open)
    @festival = festival
    @status = status.to_sym
  end

  def incidents
    @incidents ||= scope.all
  end

  def to_ary
    incidents.map { |incident| IncidentDetails.new(incident) }
  end

  def open?
    status == :open
  end

  def closed?
    status == :closed
  end

  delegate :none?, to: :incidents

  private

  def scope
    @scope ||= Incident
      .where(status: status)
      .newest_first
      .includes(:participant, latest_comment: :participant)
  end
end
