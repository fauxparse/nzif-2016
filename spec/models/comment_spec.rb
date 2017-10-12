require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { FactoryGirl.create(:comment) }

  it { is_expected.to be_valid }
  it { is_expected.not_to be_deleted }

  describe '.not_deleted' do
    subject(:comments) { Comment.not_deleted }

    it { is_expected.to include comment }
  end

  context 'when deleted' do
    before do
      comment.mark_as_deleted!
    end

    it { is_expected.to be_deleted }

    describe '.not_deleted' do
      subject(:comments) { Comment.not_deleted }

      it { is_expected.not_to include comment }
    end
  end
end
