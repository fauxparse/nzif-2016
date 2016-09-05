module ActivityHelpers
  def create_workshop(name)
    FactoryGirl.create(:workshop, name: name, festival: festival).tap do |workshop|
      FactoryGirl.create(:schedule, activity: workshop)
    end
  end

  def find_workshop_by_name(name)
    festival.activities.find_by(name: name, type: "Workshop")
  end
end

World(ActivityHelpers)
