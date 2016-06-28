require 'rails_helper'

RSpec.shared_examples_for 'a payment' do
  it { is_expected.to be_valid }
  it { is_expected.to be_pending }
  it { is_expected.to validate_numericality_of(:amount_cents)
       .is_greater_than(0) }
end

RSpec.describe Payment, type: :model do
  context 'an Internet banking payment' do
    subject(:payment) { FactoryGirl.create(:internet_banking_payment) }

    it_behaves_like 'a payment'

    describe '#payment_method' do
      subject { payment.payment_method }
      it { is_expected.to be_an_instance_of InternetBanking }
    end
  end
end
