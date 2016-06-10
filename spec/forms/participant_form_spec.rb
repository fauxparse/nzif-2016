require 'rails_helper'

describe ParticipantForm do
  subject(:form) { ParticipantForm.new(participant, params) }
  let(:params) { ActionController::Parameters.new(participant: raw_params) }
  let(:valid_params) do
    {
      name: "Alice",
      email: "alice@example.com"
    }
  end
  let(:invalid_params) { { email: "Alice" } }

  context 'for a new participant' do
    let(:participant) { nil }

    context 'with valid params' do
      let(:raw_params) { valid_params }

      it { is_expected.to be_valid }

      describe '#save' do
        it 'creates a participant' do
          expect { form.save }
            .to change { Participant.count }
            .by 1
        end

        it 'returns true' do
          expect(form.save).to be true
        end
      end
    end

    context 'with invalid params' do
      let(:raw_params) { invalid_params }

      it { is_expected.not_to be_valid }
      it { is_expected.to have_exactly(1).error_on(:email) }

      describe '#save' do
        it 'does not create a participant' do
          expect { form.save }
            .not_to change { Participant.count }
        end
      end
    end

    context 'as admin' do
      let(:raw_params) { valid_params.merge(admin: true) }

      it { is_expected.to be_valid }

      describe '#save' do
        it 'creates a participant' do
          expect { form.save }
            .to change { Participant.count }
            .by 1
        end

        it 'creates a user' do
          expect { form.save }
            .to change { User.count }
            .by 1
        end
      end
    end
  end

  context 'for an existing participant' do
    let(:participant) { FactoryGirl.create(:participant) }
    before { participant }

    context 'with valid params' do
      let(:raw_params) { valid_params }

      it { is_expected.to be_valid }

      describe '#save' do
        it 'updates the participant' do
          expect { form.save }
            .to change { Participant.first.name }
            .to "Alice"
        end
      end
    end

    context 'with invalid params' do
      let(:raw_params) { invalid_params }

      it { is_expected.not_to be_valid }

      describe '#save' do
        it 'does not update the participant' do
          expect { form.save }
            .not_to change { Participant.first.name }
        end
      end
    end
  end
end
