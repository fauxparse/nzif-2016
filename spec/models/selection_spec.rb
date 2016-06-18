require 'rails_helper'

RSpec.describe Selection, type: :model do
  subject(:selection) { FactoryGirl.create(:selection) }

  it { is_expected.to validate_presence_of(:schedule_id) }
  it { is_expected.to validate_presence_of(:registration_id) }
  it { is_expected.to validate_uniqueness_of(:schedule_id)
       .scoped_to(:registration_id) }
end
