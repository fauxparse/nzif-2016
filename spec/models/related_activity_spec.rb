require 'rails_helper'

RSpec.describe RelatedActivity, type: :model do
  subject(:related_activity) do
    RelatedActivity.new(parent: parent, child: child)
  end
  let(:festival) { FactoryGirl.create(:festival) }
  let(:parent) { FactoryGirl.create(:activity, festival: festival) }
  let(:child) { FactoryGirl.create(:activity, festival: festival) }

  context 'with a parent and a child' do
    it { is_expected.to be_valid }
  end

  context 'with a child but no parent' do
    let(:parent) { nil }
    it { is_expected.not_to be_valid }
  end

  context 'with a parent but no child' do
    let(:child) { nil }
    it { is_expected.not_to be_valid }
  end

  context 'with a duplicate child' do
    before do
      RelatedActivity.create(parent: parent, child: child)
    end
    it { is_expected.not_to be_valid }
  end
end
