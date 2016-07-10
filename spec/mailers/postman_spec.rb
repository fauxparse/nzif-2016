require "rails_helper"

RSpec.describe Postman, type: :mailer do
  describe '#registration_confirmation' do
    let(:participant) { registration.participant }
    let(:festival) { registration.festival }
    let(:registration) { FactoryGirl.create(:registration) }
    let(:email) { described_class.registration_confirmation(registration) }

    before { email.deliver_now }

    it 'sends the email' do
      expect(ActionMailer::Base.deliveries).not_to be_empty
    end

    describe '#to' do
      subject { email.to }
      it { is_expected.to eq [participant.email] }
    end

    describe '#from' do
      subject { email.from }
      it { is_expected.to eq ["noreply@nzif.info"] }
    end

    describe '#subject' do
      subject { email.subject }
      it { is_expected.to eq "Registered for NZIF 2016" }
    end
  end
end
