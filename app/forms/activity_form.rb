class ActivityForm
  attr_reader :activity

  delegate :name, :name=, :description, :description=, :image, :image=,
    :grade, :grade=, :valid?, :save, :errors, :model_name,
    to: :activity

  def initialize(activity, params = {})
    @activity = activity
    apply(sanitize(params))
  end

  def apply(params)
    params.each { |attr, value| send(:"#{attr}=", value) }
  end

  def to_model
    activity
  end

  def facilitator_ids
    activity.facilitators.map(&:participant_id)
  end

  def facilitator_ids=(ids)
    ids = Array(ids).reject(&:blank?).map(&:to_i)
    ids.each.with_index do |id, i|
      facilitator = activity.facilitators
        .detect { |facilitator| facilitator.participant_id == id } ||
        activity.facilitators.build(participant_id: id)
      facilitator.position = i
    end

    activity.facilitators.each do |f|
      f.mark_for_destruction unless ids.include?(f.participant_id)
    end
  end

  def self.parameters
    [:name, :description, :image, :grade, { facilitator_ids: [] }]
  end

  private

  def sanitize(params)
    return {} if params[:activity].blank?
    params.require(:activity).permit(*self.class.parameters)
  end
end
