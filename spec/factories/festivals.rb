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
          FactoryGirl.create(:package, name: name, festival: festival)
        end
      end
    end
  end
end
