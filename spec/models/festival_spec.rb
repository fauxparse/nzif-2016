require 'rails_helper'

RSpec.describe Festival, type: :model do
  subject(:festival) { FactoryGirl.create(:festival) }

  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:end_date) }
  it { is_expected.to validate_uniqueness_of(:year) }

  describe '#to_param' do
    subject { festival.to_param }
    it { is_expected.to eq festival.year.to_s }
  end

  context 'when year is set to nil' do
    subject(:festival) { FactoryGirl.build(:festival) }
    before do
      festival.year = nil
      expect(festival).to be_valid
    end

    describe '#year' do
      subject { festival.year }
      it { is_expected.not_to be_nil }
      it { is_expected.to eq festival.start_date.year }
    end
  end
end
