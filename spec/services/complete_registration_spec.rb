require 'rails_helper'

RSpec.describe CompleteRegistration do
  subject(:service) { described_class.new(registration) }
  let(:registration) { instance_double("Registration") }
  let(:email) { double }

  before do
    allow(registration).to receive(:update)
      .with(an_instance_of(Hash))
    allow(email).to receive(:deliver_later)
  end

  context 'when the registration has not been completed' do
    before do
      expect(registration).to receive(:complete?).and_return false
      allow(Postman).to receive(:registration_confirmation)
        .with(registration).and_return(email)
    end

    it 'updates the timestamp and sends an email' do
      Timecop.freeze do
        expect(registration)
          .to receive(:update)
          .with(completed_at: Time.now)
          .and_return(true)
        expect(email).to receive(:deliver_later)

        service.call
      end
    end
  end

  context 'when the registration has not been completed' do
    before do
      expect(registration).to receive(:complete?).and_return true
    end

    it 'does not update the timestamp' do
      expect(registration).not_to receive(:update)
      service.call
    end

    it 'does not send an email' do
      expect(Postman).not_to receive(:registration_confirmation)
      service.call
    end
  end
end
