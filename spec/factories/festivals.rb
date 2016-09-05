FactoryGirl.define do
  factory :festival do
    year 2016
    start_date do
      date = Date.new(year, 10, 1)
      date = date + 1.day while date.wday != 2
      date
    end
    end_date { start_date + 4.days }

    trait :with_packages do
      after(:create) do |festival, _|
        %w(Small Medium Large).each do |name|
          FactoryGirl.create(:package, :with_limits, name: name, festival: festival)
        end
      end
    end

    trait :with_activities do
      after(:create) do |festival, _|
        10.times do |i|
          workshop = FactoryGirl.create(:workshop, festival: festival)
          FactoryGirl.create(
            :schedule,
            activity: workshop,
            starts_at: festival.start_date.midnight + i * workshop.duration
          )
        end
      end
    end

    trait :with_internet_banking do
      after(:create) do |festival, _|
        FactoryGirl.create(:internet_banking_configuration, festival: festival)
      end
    end
  end
end
