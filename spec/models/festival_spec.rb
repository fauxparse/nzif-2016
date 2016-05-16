require 'rails_helper'

RSpec.describe Festival, type: :model do
  subject { FactoryGirl.create(:festival) }

  it { is_expected.to validate_presence_of(:year) }
  it { is_expected.to validate_presence_of(:start_date) }
  it { is_expected.to validate_presence_of(:end_date) }
  it { is_expected.to validate_uniqueness_of(:year) }
end
