module FestivalHelpers
  def festival(year = nil)
    raise ArgumentError, "call festival with a year first" \
      unless year || @festival

    @festival ||= FactoryGirl.create(
      :festival,
      :with_packages,
      :with_activities,
      :with_internet_banking,
      year: year
    )
  end
end

World(FestivalHelpers)
