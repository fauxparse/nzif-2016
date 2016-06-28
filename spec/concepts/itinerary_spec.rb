require 'rails_helper'

describe Itinerary do
  subject(:itinerary) { Itinerary.new(registration) }
  let(:registration) do
    FactoryGirl.create(
      :registration,
      festival: festival,
      package: package
    )
  end
  let(:festival) { FactoryGirl.create(:festival) }
  let(:package) do
    FactoryGirl.create(:package, :with_limits, festival: festival)
  end
  let(:selections) { {} }

  before do
    start_time = festival.start_date.midnight
    selections.each do |type, count|
      count.times do |i|
        activity = type.create(
          name: "#{type.name} ##{i}",
          festival: festival
        )
        schedule = activity.schedules.create(
          activity: activity,
          starts_at: start_time,
          ends_at: start_time + activity.duration
        )
        start_time += activity.duration
        registration.selections.build(schedule: schedule)
      end
    end
  end

  context 'with no selections' do
    it { is_expected.to be_valid }
  end

  context 'with a reasonable number of selections' do
    let(:selections) { { Workshop => 2, Show => 1, SocialEvent => 3 } }
    it { is_expected.to be_valid }
  end

  context 'with an unreasonable number of selections' do
    let(:selections) do
      { Workshop => 5, Show => 1, SocialEvent => 3, Discussion => 1 }
    end

    it { is_expected.not_to be_valid }

    it 'has too many workshops' do
      expect(itinerary.errors_on(:base))
        .to include("Too many workshops selected (maximum is 3)")
    end

    it 'has too many discussions' do
      expect(itinerary.errors_on(:base))
        .to include("Your package does not include any discussions")
    end
  end

  context 'trying to book for a full workshop' do
    let(:workshop) { FactoryGirl.create(:workshop, festival: festival) }
    let(:schedule) { FactoryGirl.create(:schedule, activity: workshop, maximum: 1) }
    let(:other_registration) { FactoryGirl.create(:registration, festival: festival, package: package) }
    before do
      Selection.create(registration: other_registration, schedule: schedule)
      registration.selections.build(schedule: schedule)
    end

    it { is_expected.not_to be_valid }
    it 'notifies the user of a full session' do
      expect(itinerary.errors_on(:base))
        .to include("That session of #{workshop.name} is full")
    end
  end
end
