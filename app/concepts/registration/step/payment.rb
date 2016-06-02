class Registration::Step::Payment < Registration::Step
  def complete?
    true
  end

  def self.parameters
    []
  end
end
