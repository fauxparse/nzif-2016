require 'rails_helper'

RSpec.shared_context 'a week before the festival' do
  before { Timecop.freeze(festival.start_date.midnight - 1.week) }
  after { Timecop.return }
end

RSpec.shared_context 'a month before the festival' do
  before { Timecop.freeze(festival.start_date.midnight - 1.month) }
  after { Timecop.return }
end

RSpec.shared_context 'a week after the festival' do
  before { Timecop.freeze(festival.end_date.succ.midnight + 1.week) }
  after { Timecop.return }
end

RSpec.shared_context 'an earlybird discount is available' do
  let(:earlybird) do
    FactoryGirl.create(
      :package_price,
      package: package,
      expires_at: festival.start_date.midnight - 2.weeks
    )
  end
  before { earlybird }
end

RSpec.describe PackagePrice, type: :model do
  subject(:price) { package.prices.expiring_first.last }
  let(:package) { FactoryGirl.create(:package) }
  let(:festival) { package.festival }

  it { is_expected.to be_valid }

  describe '#available?' do
    context 'before the festival' do
      include_context 'a week before the festival'
      it { is_expected.to be_available }
    end

    context 'after the festival' do
      include_context 'a week after the festival'
      it { is_expected.not_to be_available }
    end
  end

  describe '#available_at?' do
    it { is_expected.to be_available_at(festival.start_date.midnight - 1.week) }
  end

  describe '.available_at' do
    subject(:available) { package.prices.available_at(Time.now).first }

    context 'a month before the festival' do
      include_context 'a month before the festival'
      it { is_expected.to eq price }

      context 'when an earlybird discount is available' do
        include_context 'an earlybird discount is available'
        it { is_expected.to eq earlybird }
      end
    end

    context 'a week before the festival' do
      include_context 'a week before the festival'
      it { is_expected.to eq price }

      context 'when an earlybird discount is available' do
        include_context 'an earlybird discount is available'
        it { is_expected.to eq price }
      end
    end

    context 'a week after the festival' do
      include_context 'a week after the festival'
      it { is_expected.to be_nil }
    end
  end

  describe '#amount' do
    subject(:amount) { price.amount }

    it 'is priced in NZD' do
      expect(amount.currency).to eq :nzd
    end
  end
end
