require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the DatesHelper. For example:
#
# describe DatesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe DatesHelper, type: :helper do
  describe '#date_range' do
    subject { helper.date_range(start_date, end_date) }
    let(:start_date) { Date.new(2016, 4, 1) }

    context 'when the start and end dates are identical' do
      let(:end_date) { start_date }
      it { is_expected.to eq "1 April, 2016" }
    end

    context 'when the start and end dates are in the same month' do
      let(:end_date) { start_date + 4.days }
      it { is_expected.to eq "1–5 April, 2016" }
    end

    context 'when the start and end dates are in different months' do
      let(:end_date) { start_date + 1.month }
      it { is_expected.to eq "1 April – 1 May, 2016" }
    end

    context 'when the start and end dates are in different years' do
      let(:end_date) { start_date + 1.year }
      it { is_expected.to eq "1 April, 2016 – 1 April, 2017" }
    end
  end
end
