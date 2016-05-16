FactoryGirl.define do
  factory :festival do
    year 2016
    start_date do
      date = Date.new(year, 10, 1)
      date = date + 1.day while date.wday != 2
      date
    end
    end_date { start_date + 4.days }
  end
end
