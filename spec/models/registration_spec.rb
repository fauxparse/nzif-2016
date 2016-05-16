require 'rails_helper'

RSpec.describe Registration, type: :model do
  subject(:registration) { FactoryGirl.create(:registration) }

  it { is_expected.to validate_presence_of(:participant) }
  it { is_expected.to validate_presence_of(:festival) }
end
