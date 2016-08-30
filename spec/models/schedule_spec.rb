require 'rails_helper'

RSpec.describe Schedule, type: :model do
  subject(:schedule) { FactoryGirl.create(:schedule) }

  describe 'with no limit' do
    before { schedule.maximum = nil }
    it { is_expected.to be_valid }
    it { is_expected.not_to be_limited }
  end
end
