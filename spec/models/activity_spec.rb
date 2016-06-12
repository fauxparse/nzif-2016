require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { FactoryGirl.create(:workshop) }

  it { is_expected.to validate_uniqueness_of(:name)
       .scoped_to(:festival_id).case_insensitive }
end
