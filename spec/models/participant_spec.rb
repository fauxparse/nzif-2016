require 'rails_helper'

RSpec.describe Participant, type: :model do
  context 'without a user' do
    subject(:participant) { FactoryGirl.create(:participant) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  context 'with a user' do
    subject(:participant) do
      FactoryGirl.create(:participant, :with_associated_user)
    end

    it { is_expected.to validate_presence_of(:name) }

    describe '#email' do
      subject { participant.email }
      it { is_expected.to eq participant.user.email }
    end
  end
end
