class Registration::Step
  include Cry
  include ActiveModel::Validations

  attr_reader :registration

  delegate :festival, :participant, :package, to: :registration

  def initialize(registration)
    @registration = registration
  end

  def apply(params)
    apply_filtered_parameters(filter_parameters(params))
    valid? && continue || publish(:error, registration)
  end

  def valid?
    errors.empty?
  end

  def id
    self.class.name.demodulize.underscore.to_sym
  end

  def to_partial_path
    id.to_s
  end

  def to_param
    id
  end

  def description
    I18n.translate("registrations.steps.#{id}")
  end

  def complete?
    false
  end

  def pending?
    !complete?
  end

  def self.parameters
    ids
      .flat_map { |id| "#{name}::#{id.to_s.camelize}".constantize.parameters }
      .uniq
  end

  def self.ids
    %i[details activities code_of_conduct payment]
  end

  def self.list(registration)
    ids.map { |step| get(registration, step) }
  end

  def self.get(registration, id)
    step_class = "#{name}::#{id.to_s.camelize}".constantize
    step_class.new(registration)
  end

  private

  def apply_filtered_parameters(params)
    registration.update!(params)
  end

  def filter_parameters(params)
    if params[:registration].present?
      params.require(:registration).permit(*self.class.parameters)
    else
      {}
    end
  end

  def continue
    publish(:success, registration)
  end
end
