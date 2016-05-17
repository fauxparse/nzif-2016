require "rails_helper"

RSpec.describe ParticipantMailer, type: :mailer do
  describe '#registration_email' do
    let(:participant) { registration.participant }
    let(:festival) { registration.festival }
    let(:registration) { FactoryGirl.create(:registration) }
    let(:email) { ParticipantMailer.registration_email(registration) }

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
