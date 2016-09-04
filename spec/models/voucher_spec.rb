require 'rails_helper'

RSpec.describe Voucher, type: :model do
  subject(:voucher) { FactoryGirl.create(:voucher) }

  it { is_expected.to be_valid }
end
