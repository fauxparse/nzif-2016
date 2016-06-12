class ActivityForm
  attr_reader :activity

  delegate :name, :name=, :description, :description=,
    :valid?, :save, :errors,
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

  def self.parameters
    %i[name description]
  end

  private

  def sanitize(params)
    return {} if params[:activity].blank?
    params.require(:activity).permit(*self.class.parameters)
  end
end
