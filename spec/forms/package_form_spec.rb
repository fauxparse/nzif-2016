require 'rails_helper'

describe PackageForm do
  subject(:form) { PackageForm.new(package, params) }
  let(:params) { ActionController::Parameters.new(package: raw_params) }
  let(:valid_params) do
    {
      name: "Fancy",
      allocations: {
        workshops: 2,
        shows: 2,
        social_events: nil,
        discussions: 0
      }
    }
  end
  let(:invalid_params) { { name: "" } }

  context 'for a new package' do
    let(:package) { Package.new }

    describe '#save' do
      context 'with valid parameters' do
        let(:raw_params) { valid_params }

        it 'creates a package' do
          expect { form.save }.to change { Package.count }.by 1
        end

        it 'creates allocations' do
          expect { form.save }.to change { Allocation.count }.by 4
        end
      end

      context 'with invalid parameters' do
        let(:raw_params) { invalid_params }

        it 'does not create a package' do
          expect { form.save }.not_to change { Package.count }
        end

        it 'creates allocations' do
          expect { form.save }.not_to change { Allocation.count }
        end

        it 'has errors' do
          form.save
          expect(form).to have_exactly(1).error_on(:name)
        end
      end
    end
  end

  context 'for an existing package' do
    let(:package) { FactoryGirl.create(:package) }

    describe '#save' do
      context 'with valid parameters' do
        let(:raw_params) { valid_params }

        it 'updates the name' do
          expect { form.save }.to change { package.name }.to "Fancy"
        end

        it 'updates the allocations' do
          form.save
          allocation = package.allocations
            .find_by(activity_type_name: "social_events")
          expect(allocation).to be_unlimited
        end
      end
    end
  end
end
