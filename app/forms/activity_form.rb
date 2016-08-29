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
    ids = sanitize_ids(ids)
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

  def related_activity_ids
    activity.related_activities.map(&:child_id)
  end

  def related_activity_ids=(ids)
    ids = sanitize_ids(ids)
    ids.each.with_index do |id, i|
      related = activity.related_activities
        .detect { |related| related.child_id == id } ||
        activity.related_activities.build(child_id: id)
    end

    activity.related_activities.each do |related|
      related.mark_for_destruction unless ids.include?(related.child_id)
    end
  end

  def self.parameters
    [
      :name,
      :description,
      :image,
      :grade,
      {
        facilitator_ids: [],
        related_activity_ids: []
      }
    ]
  end

  private

  def sanitize(params)
    return {} if params[:activity].blank?
    params.require(:activity).permit(*self.class.parameters)
  end

  def sanitize_ids(ids)
    Array(ids).reject(&:blank?).map(&:to_i)
  end
end
