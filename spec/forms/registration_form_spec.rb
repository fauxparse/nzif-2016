require 'rails_helper'

describe RegistrationForm do
  subject(:form) { RegistrationForm.new(festival, participant) }
  let(:festival) { FactoryGirl.create(:festival) }
  let(:participant) { nil }
  let(:params) { ActionController::Parameters.new(registration: raw_params) }
  let(:raw_params) { nil }
  let(:save) { form.apply(params) }

  shared_examples_for "a form with an existing user" do
    describe '#step' do
      before { save }
      subject { form.step }
      it { is_expected.to be_valid }
    end

    it 'has a user' do
      expect(form.user).to be_present
    end

    describe 'applying the details step' do
      it 'does not create a user' do
        expect { save }.not_to change { User.count }
      end

      it 'does not create a participant' do
        expect { save }.not_to change { Participant.count }
      end

      it 'creates a registration' do
        expect { save }.to change { Registration.count }.by 1
      end
    end
  end

  describe '#steps' do
    subject { form.steps }
    it { is_expected.to have_exactly(3).items }
  end

  context 'for a new user' do
    let(:name) { "Alice" }
    let(:email) { "alice@example.com" }
    let(:password) { "p4$$w0rd" }
    let(:raw_params) do
      {
        name: name,
        email: email,
        password: password,
        password_confirmation: password
      }
    end

    describe '#step' do
      before { save }
      subject { form.step }
      it { is_expected.to be_an_instance_of(Registration::Step::Details) }
      it { is_expected.to be_valid }
    end

    describe 'applying the details step' do
      it 'creates a user' do
        expect { save }.to change { User.count }.by 1
      end

      describe 'created user' do
        before { save }
        subject(:new_user) { User.last }

        it 'has the correct email' do
          expect(new_user.email).to eq email
        end
      end

      it 'creates a participant' do
        expect { save }.to change { Participant.count }.by 1
      end

      describe 'created participant' do
        before { save }
        subject(:new_participant) { Participant.first }

        it 'has the correct name' do
          expect(new_participant.name).to eq name
        end

        it 'has the correct email' do
          expect(new_participant.email).to eq email
        end

        it 'stores the email on the user' do
          expect(new_participant.read_attribute(:email)).to be_blank
        end

        it 'has the correct user' do
          expect(new_participant.user).to eq User.last
        end
      end

      it 'creates a registration' do
        expect { save }.to change { Registration.count }.by 1
      end

      describe 'created registration' do
        subject(:new_registration) { Registration.last }
        before { save }

        it 'has the correct participant' do
          expect(new_registration.participant).to eq Participant.last
        end
      end

      context 'when email is missing' do
        let(:email) { nil }

        xit 'fails validation' do
          expect { save }.to raise_error(ActiveModel::ValidationError)
        end

        it 'has an error on the email attribute' do
          save rescue expect(form).to have_exactly(1).error_on(:email)
        end
      end
    end
  end

  context 'for an existing participant' do
    before { participant }
    let(:participant) do
      FactoryGirl.create(:participant, :with_associated_user)
    end
    let(:raw_params) { {} }

    it_behaves_like "a form with an existing user"
  end

  context 'for a participant created without a user' do
    before { participant }

    let(:participant) { FactoryGirl.create(:participant) }
    let(:password) { "p4$$w0rd" }
    let(:raw_params) do
      {
        name: "Alice",
        email: participant.email.capitalize + " ",
        password: password,
        password_confirmation: password
      }
    end

    describe '#step' do
      before { save }
      subject { form.step }
      it { is_expected.to be_valid }
    end

    describe 'applying the details step' do
      it 'creates a user' do
        expect { save }.to change { User.count }.from(0).to(1)
      end

      it 'does not create a participant' do
        expect { save }.not_to change { Participant.count }
      end

      it 'creates a registration' do
        expect { save }.to change { Registration.count }.by 1
      end

      it 'updates the participant’s name' do
        expect { save }
          .to change { Participant.first.name }
          .to "Alice"
      end
    end
  end
end
