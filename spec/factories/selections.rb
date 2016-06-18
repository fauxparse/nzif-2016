FactoryGirl.define do
  factory :selection do
    schedule
    registration do
      FactoryGirl.create(:registration, festival: schedule.activity.festival)
    end
  end
end
