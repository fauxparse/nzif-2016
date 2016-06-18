FactoryGirl.define do
  factory :schedule do
    activity
    starts_at { activity.festival.start_date.midnight + 10.hours }
    ends_at { starts_at + activity.duration }
  end
end
