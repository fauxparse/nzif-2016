require 'rails_helper'

RSpec.describe CreatePayment do
  subject(:service) { described_class.new(registration, params) }
  let(:params) { { amount: "100", payment_type: "internet_banking" } }
  let(:result) { double }
  let(:registration) { FactoryGirl.create(:registration, festival: festival) }
  let(:festival) { FactoryGirl.create(:festival, :with_internet_banking) }

  it 'creates a payment' do
    expect { service.call }
      .to change { registration.payments.count }.by 1
  end

  it 'publishes success' do
    expect(result).to receive(:success).with(an_instance_of(Payment))
    service.on(:success) { |payment| result.success(payment) }
    service.call
  end

  context 'when there is a fee on payments' do
    before do
      festival.payment_configurations
        .first.update(transaction_fee: 2)
    end

    describe 'the payment' do
      before { service.call }
      subject(:payment) { service.payment }

      it 'should have a $2 fee' do
        expect(payment.fee.format).to eq '$2'
      end
    end
  end
end
