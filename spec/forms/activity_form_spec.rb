require 'rails_helper'

describe ActivityForm do
  subject(:form) { ActivityForm.new(activity, params) }
  let(:festival) { FactoryGirl.create(:festival) }
  let(:participant) { FactoryGirl.create(:participant) }
  let(:params) { ActionController::Parameters.new(activity: raw_params) }
  let(:valid_params) do
    {
      name: "A workshop",
      description: "Lorem ipsum dolor sit amet",
      facilitator_ids: [participant.id]
    }
  end
  let(:invalid_params) { { name: "" } }

  context 'for a new activity' do
    let(:activity) { Workshop.new(festival: festival) }

    context 'with valid parameters' do
      let(:raw_params) { valid_params }

      it { is_expected.to be_valid }

      describe '#save' do
        it 'creates a workshop' do
          expect { form.save }
            .to change { Workshop.count }
            .by 1
        end

        it 'creates a facilitator' do
          expect { form.save }
            .to change { Facilitator.count }
            .by 1
        end

        it 'creates the right facilitator' do
          form.save
          expect(form.activity.facilitators.map(&:participant))
            .to include(participant)
        end
      end
    end

    context 'with invalid parameters' do
      let(:raw_params) { invalid_params }

      it { is_expected.not_to be_valid }

      describe '#save' do
        subject(:save) { form.save }

        it { is_expected.to be_falsy }

        it 'does not create a new activity' do
          expect { save }.not_to change { Activity.count }
        end
      end
    end
  end

  context 'for an existing activity' do
    let(:activity) do
      FactoryGirl.create(:workshop, :facilitated, festival: festival)
    end
    before { activity }

    context 'with valid parameters' do
      let(:raw_params) { valid_params }

      it { is_expected.to be_valid }

      describe '#save' do
        it 'does not create a new workshop' do
          expect { form.save }
            .not_to change { Workshop.count }
        end

        it 'changes the workshop name' do
          expect { form.save }
            .to change { Workshop.first.name }
            .to "A workshop"
        end

        it 'updates the facilitators' do
          expect { form.save }
            .to change { Facilitator.count }
            .from(2)
            .to(1)
        end
      end
    end

    context 'with invalid parameters' do
      let(:raw_params) { invalid_params }

      it { is_expected.not_to be_valid }

      describe '#save' do
        subject(:save) { form.save }

        it { is_expected.to be_falsy }

        it 'does not change existing activities' do
          expect { save }.not_to change { Workshop.first.name }
        end
      end
    end
  end
end
