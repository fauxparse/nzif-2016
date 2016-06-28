require 'rails_helper'

RSpec.shared_examples_for 'an account' do
  describe '#total' do
    subject(:total) { account.total }
    it { is_expected.to eq Money.new(expected_total * 100, :nzd) }
  end
end

RSpec.describe Account do
  subject(:account) { Account.new(registration, now) }
  let(:now) { Time.now }
  let(:festival) { registration.festival }
  let(:registration) do
    FactoryGirl.create(:registration, created_at: Date.new(2016, 8, 1))
  end

  after { Timecop.return }

  def price(amount, expiry)
    PackagePrice.new(
      amount: amount,
      deposit: amount / 2,
      expires_at: expiry
    )
  end

  def pay(amount, date)
    Timecop.travel(date)
    FactoryGirl.create(
      :internet_banking_payment,
      amount: amount,
      registration: registration
    ).approve!
    Timecop.return
  end

  context 'when the deposit is paid in a single payment before the first date' do
    before do
      pay(200, Date.new(2016, 8, 1))
    end

    let(:expected_total) { 400 }
    it_behaves_like 'an account'
  end

  context 'when the deposit is paid in a several payments before the first date' do
    before do
      pay(100, Date.new(2016, 8, 1))
      pay(100, Date.new(2016, 8, 2))
    end

    let(:expected_total) { 400 }
    it_behaves_like 'an account'
  end

  context 'when no payment has been made' do
    context 'but we are still before the first date' do
      let(:now) { Time.zone.local(2016, 8, 1) }
      let(:expected_total) { 400 }
      it_behaves_like 'an account'
    end

    context 'and we are after the first date' do
      let(:now) { Time.zone.local(2016, 9, 15) }
      let(:expected_total) { 500 }
      it_behaves_like 'an account'
    end

    context 'and we are after the festival' do
      let(:now) { Time.zone.local(2016, 11, 1) }
      let(:expected_total) { 500 }
      it_behaves_like 'an account'
    end
  end
end
