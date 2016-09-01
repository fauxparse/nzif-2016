class Registration::Step::CodeOfConduct < Registration::Step
  def complete?
    code_of_conduct_accepted
  end

  def self.parameters
    %i[code_of_conduct_accepted]
  end

  def code_of_conduct_accepted
    registration.code_of_conduct_accepted?
  end

  private

  def apply_filtered_parameters(params)
    registration.update(code_of_conduct_accepted_at: Time.now) \
      if params[:code_of_conduct_accepted].present?
  end
end

