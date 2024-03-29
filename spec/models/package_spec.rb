require 'rails_helper'

RSpec.describe Package, type: :model do
  subject(:package) { FactoryGirl.create(:package) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:name)
        .scoped_to(:festival_id).case_insensitive }

  context 'without prices' do
    subject(:package) { FactoryGirl.build(:package) }
    before { package.prices.clear }
    it { is_expected.not_to be_valid }
  end
end
