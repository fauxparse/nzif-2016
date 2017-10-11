class IncidentDetails < SimpleDelegator
  include PrettyPresenters

  alias_method :incident, :__getobj__

  def description
    pretty(incident.description)
  end

  def date
    incident.created_at.to_date
  end

  def time
    incident.created_at.to_time
  end

  def reporter
    if incident.anonymous?
      I18n.t('admin.incidents.incident.anonymous')
    else
      incident.participant.name
    end
  end

  def self.new(incident)
    incident && super(incident)
  end
end
