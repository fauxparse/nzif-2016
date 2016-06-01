class Registration::Step::Package < Registration::Step
  def complete?
    # !package_selection_required? || package.present?
    true
  end

  private

  def package_selection_required?
    festival.packages.count > 1
  end
end
