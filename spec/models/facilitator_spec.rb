require 'rails_helper'

RSpec.describe Facilitator, type: :model do
  subject(:facilitator) { FactoryGirl.create(:facilitator) }

  it { is_expected.to be_valid }
end
