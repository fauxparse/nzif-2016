require 'rails_helper'

describe Registration::Step::Details do
  subject(:step) { described_class.new(registration) }
  let(:festival) { FactoryGirl.create(:festival) }
  let(:registration) { festival.registrations.build(participant: participant) }
  let(:participant) { Participant.new }
  let(:apply) { step.apply(parameters) }

  let(:parameters) do
    ActionController::Parameters.new(registration: raw_parameters)
  end

  let(:raw_parameters) do
    {
      name: "Alice",
      email: "alice@example.com",
      password: "pa$$w0rd!",
      password_confirmation: "pa$$w0rd!"
    }
  end

  context 'for a new participant' do
    context 'with valid parameters' do
      describe '#apply' do
        it 'is valid' do
          apply
          expect(step).to be_valid
        end

        it 'creates a user' do
          expect { apply }.to change { User.count }.by(1)
        end

        it 'creates a participant' do
          expect { apply }.to change { Participant.count }.by(1)
        end

        it 'creates a registration' do
          expect { apply }.to change { Registration.count }.by(1)
        end
      end
    end
  end

  context 'for an existing participant with no user' do
    let(:existing) { FactoryGirl.create(:participant) }
    let(:raw_parameters) do
      {
        name: "Alice",
        email: existing.email,
        password: "p4$$w0rd!",
        password_confirmation: "p4$$w0rd!"
      }
    end

    before { existing }

    context 'with valid parameters' do
      describe '#apply' do
        it 'is valid' do
          apply
          expect(step).to be_valid
        end

        it 'creates a user' do
          expect { apply }.to change { User.count }.by(1)
        end

        it 'does not create a participant' do
          expect { apply }.not_to change { Participant.count }
        end

        it 'creates a registration' do
          expect { apply }.to change { Registration.count }.by(1)
        end

        it 'updates the participant' do
          expect { apply }
            .to change { Participant.first.name }
            .to raw_parameters[:name]
        end
      end
    end
  end

  context 'for an existing participant with an associated user' do
    let(:existing) do
      FactoryGirl.create(:participant, :with_associated_user)
    end

    before { existing }

    context 'trying to hijack an email address' do
      let(:raw_parameters) do
        {
          name: "Imposter",
          email: existing.email,
          password: "br0k3n!",
          password_confirmation: "br0k3n!"
        }
      end

      describe '#apply' do
        before { apply }
        it { is_expected.not_to be_valid }
        it { is_expected.to have_exactly(1).error_on(:email) }
      end
    end

    context 'trying to log in as an existing user' do
      let(:raw_parameters) do
        {
          name: "Alice",
          email: existing.email,
          password: existing.user.password,
          password_confirmation: existing.user.password
        }
      end

      describe '#apply' do
        it 'is valid' do
          apply
          expect(step).to be_valid
        end

        it 'does not create a user' do
          expect { apply }.not_to change { User.count }
        end

        it 'does not create a participant' do
          expect { apply }.not_to change { Participant.count }
        end

        it 'creates a registration' do
          expect { apply }.to change { Registration.count }.by(1)
        end

        it 'updates the participant' do
          expect { apply }
            .to change { Participant.first.name }
            .to raw_parameters[:name]
        end
      end
    end
  end
end
