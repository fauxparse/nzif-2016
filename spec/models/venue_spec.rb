require 'rails_helper'

RSpec.describe Venue, type: :model do
  subject(:venue) { FactoryGirl.create(:venue) }

  it { is_expected.to be_valid }
  it { is_expected.to validate_uniqueness_of(:name).case_insensitive }

  it 'generates latitude and longitude' do
    expect(venue.latitude).to be_within(1e-4).of(-41.2935391)
    expect(venue.longitude).to be_within(1e-4).of(174.784505)
  end
end
