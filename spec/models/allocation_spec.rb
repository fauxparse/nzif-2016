require 'rails_helper'
require 'support/accept_matcher'

RSpec.describe Allocation, type: :model do
  subject(:allocation) { FactoryGirl.create(:allocation) }

  it { is_expected.to be_valid }

  describe '#activity_type' do
    context 'when blank' do
      before { allocation.activity_type = nil }
      it { is_expected.not_to be_valid }
    end

    context 'when an invalid type' do
      before { allocation.activity_type = Activity }
      it { is_expected.not_to be_valid }
    end
  end

  describe '#accepts?' do
    it { is_expected.not_to accept -1 }

    context 'when limited' do
      before { allocation.maximum = 3 }
      it { is_expected.to accept 3 }
      it { is_expected.not_to accept 5 }
    end

    context 'when unlimited' do
      before { allocation.maximum = nil }
      it { is_expected.to accept 5 }
    end
  end
end
