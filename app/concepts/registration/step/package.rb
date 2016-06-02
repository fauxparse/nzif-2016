class Registration::Step::Package < Registration::Step
  delegate :package_id, to: :registration

  def complete?
    !package_selection_required? || package.present?
  end

  def self.parameters
    %i[package_id]
  end

  private

  def package_selection_required?
    festival.packages.count > 1
  end
end
