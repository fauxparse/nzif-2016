require 'rails_helper'

describe NavigationHelper do
  before do
    # this is dodgy af
    def helper.festival; nil; end
    allow(helper)
      .to receive(:festival)
      .and_return(festival)
  end

  describe '#homepage_link' do
    subject { helper.homepage_link }

    context 'with a festival' do
      let(:festival) { FactoryGirl.create(:festival, year: 2016) }
      it { is_expected.to eq "<a class=\"homepage-link\" href=\"/2016\">NZIF 2016</a>" }
    end

    context 'without a festival' do
      let(:festival) { nil }
      it { is_expected.to eq "<a class=\"homepage-link\" href=\"/\">NZIF</a>" }
    end
  end
end
