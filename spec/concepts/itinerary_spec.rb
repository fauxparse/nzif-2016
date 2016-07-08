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

  def create_schedule(type, number, start_time)
    activity = type.create(
      name: "#{type.name} ##{number}",
      festival: festival
    )
    schedule = activity.schedules.create(
      activity: activity,
      starts_at: start_time,
      ends_at: start_time + activity.duration
    )
  end

  before do
    start_time = festival.start_date.midnight
    selections.each do |type, count|
      count.times do |i|
        schedule = create_schedule(type, i, start_time)
        start_time += schedule.activity.duration
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

  context 'with full complement of selections' do
    let(:selections) { { Workshop => 3, Show => 3, SocialEvent => 3 } }
    it { is_expected.to be_valid }
    it { is_expected.to be_complete }
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

  describe '#update' do
    let(:old_selections) { [] }
    let(:new_selections) { [] }
    let(:schedules) do
      start_time = festival.start_date.midnight
      (1...10).map do |i|
        create_schedule(Workshop, i, start_time).tap do |schedule|
          start_time += schedule.activity.duration
        end
      end
    end

    before do
      old_selections.each do |schedule|
        registration.selections.create!(schedule: schedule)
      end
    end

    subject(:update) { itinerary.update(selections: new_selections.map(&:id)) }

    context 'when nothing is initially selected' do
      context 'and nothing is chosen' do
        it 'doesn’t create new selections' do
          expect { update }.not_to change { Selection.count }
        end
      end

      context 'and two activities are chosen' do
        let(:new_selections) { schedules[0, 2] }
        it 'creates new selections' do
          expect { update }.to change { Selection.count }.by(2)
        end
      end
    end

    context 'when two activities are initially selected' do
      let(:old_selections) { schedules[0, 2] }

      context 'and nothing is chosen' do
        it 'deletes the selections' do
          expect { update }.to change { Selection.count }.by(-2)
        end
      end

      context 'and the same two activities are chosen' do
        let(:new_selections) { old_selections }
        it 'doesn’t create new selections' do
          expect { update }.not_to change { Selection.count }
        end
      end

      context 'and some different activities are chosen' do
        let(:new_selections) { schedules[1, 3] }

        it 'creates new selections' do
          expect { update }.to change { Selection.count }.by(1)
        end

        it 'deselects the old activities' do
          expect { update }
            .to change { itinerary.selected?(schedules[0]) }
            .from(true).to(false)
        end

        it 'selects the newly-chosen activities' do
          expect { update }
            .to change { itinerary.selected?(schedules[2]) }
            .from(false).to(true)
        end
      end

      context 'and a third activity is chosen' do
        let(:new_selections) { schedules[0, 3] }
        it 'creates new selections' do
          expect { update }.to change { Selection.count }.by(1)
        end
      end
    end
  end
end
