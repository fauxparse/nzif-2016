require 'rails_helper'

RSpec.describe Comment, type: :model do
  subject(:comment) { FactoryGirl.create(:comment) }

  it { is_expected.to be_valid }
  it { is_expected.not_to be_deleted }

  it 'does not create a revision' do
    expect(comment.previous_revision).to be_blank
  end

  describe '.not_deleted' do
    subject(:comments) { Comment.not_deleted }

    it { is_expected.to include comment }
  end

  context 'when deleted' do
    before do
      comment.mark_as_deleted!
    end

    it { is_expected.to be_deleted }

    it 'does not create a revision' do
      expect(comment.previous_revision).to be_blank
    end

    describe '.not_deleted' do
      subject(:comments) { Comment.not_deleted }

      it { is_expected.not_to include comment }
    end
  end

  context 'when edited' do
    it 'creates a revision' do
      expect { comment.update!(content: 'edited') }
        .to change { comment.revisions.count }
        .by(1)
      expect(comment).to be_edited
    end
  end
end
