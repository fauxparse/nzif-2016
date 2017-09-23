require 'rails_helper'

RSpec.describe Incident, type: :model do
  subject(:incident) { FactoryGirl.create(:incident) }

  it { is_expected.to be_valid }
  it { is_expected.to be_open }
  it { is_expected.not_to be_anonymous }
  it { is_expected.to validate_presence_of :description }

  context 'reported anonymously' do
    subject(:incident) { FactoryGirl.create(:incident, :anonymous) }

    it { is_expected.to be_valid }
    it { is_expected.to be_anonymous }

    it 'has no record of the participant' do
      expect(incident.participant).to be_blank
    end
  end
end
