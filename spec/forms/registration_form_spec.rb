require 'rails_helper'

describe RegistrationForm do
  subject(:form) { RegistrationForm.new(festival, participant) }
  let(:festival) { FactoryGirl.create(:festival, :with_packages) }
  let(:participant) { nil }
  let(:params) { ActionController::Parameters.new(registration: raw_params) }
  let(:raw_params) { nil }
  let(:apply) { form.apply(params) }

  context 'without a user' do
    describe '#step' do
      subject { form.step }
      it { is_expected.to be_an_instance_of(Registration::Step::Details) }
    end

    describe '#apply' do
      let(:raw_params) do
        FactoryGirl.attributes_for(:user).merge(name: "Alice")
      end

      it 'advances the step' do
        expect { apply }
          .to change { form.step.id }
          .from(:details)
          .to(:activities)
      end

      it 'saves the participant' do
        expect { apply }
          .to change { form.participant.new_record? }
          .from(true)
          .to(false)
      end

      it 'saves the user' do
        expect { apply }
          .to change { form.user.new_record? }
          .from(true)
          .to(false)
      end
    end
  end

  context 'with a user' do
    let(:participant) do
      FactoryGirl.create(:participant, :with_associated_user)
    end

    context 'but no package selected' do
      before do
        festival.registrations.create(participant: participant)
      end

      describe '#step' do
        subject { form.step }
        it { is_expected.to be_an_instance_of(Registration::Step::Activities) }
      end

      describe '#apply' do
        let(:raw_params) { { package_id: festival.packages.first.id } }

        it 'advances the step' do
          expect { apply }
            .to change { form.step.id }
            .from(:activities)
            .to(:payment)
        end
      end
    end

    context 'and a package selected' do
      let(:package) { festival.packages.first }
      let(:registration) do
        festival.registrations.create(
          participant: participant,
          package: package
        )
      end

      before { registration }

      describe '#step' do
        subject { form.step }
        it { is_expected.to be_an_instance_of(Registration::Step::Payment) }
      end

      context 'and a payment made' do
        before do
          registration.payments.create!(
            amount: registration.package.prices.last.amount,
            payment_type: 'internet_banking'
          )
        end

        it { is_expected.to be_complete }
      end
    end
  end

  describe '.permitted_attributes' do
    subject { RegistrationForm.permitted_attributes }
    let(:all_attributes) do
      %i[
        name
        email
        password
        password_confirmation
        package_id
        payment_type
        amount
      ] + [{ :selections => [] }]
    end

    it { is_expected.to match_array(all_attributes) }
  end

  describe '#step=' do
    context 'when details have not been completed' do
      it 'cannot move to package selection' do
        expect { form.step = :activities }
          .not_to change { form.step.id }
      end
    end

    context 'when details have not been completed' do
      before do
        allow_any_instance_of(Registration::Step::Details)
          .to receive(:complete?)
          .and_return(true)
      end

      it 'is in the package step by default' do
        expect(form.step.id).to eq :activities
      end

      it 'cannot move to package selection' do
        expect { form.step = :details }
          .to change { form.step.id }
          .from(:activities)
          .to(:details)
      end
    end
  end
end
