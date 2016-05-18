require 'rails_helper'

describe ErrorMessagesHelper do
  describe '#error_messages_for' do
    subject(:error_messages) do
      helper.error_messages_for(participant, :name)
    end

    before { participant.validate }

    context 'for a valid participant' do
      let(:participant) { FactoryGirl.build(:participant) }
      it { is_expected.to be_blank }
    end

    context 'for an invalid participant' do
      let(:participant) { FactoryGirl.build(:participant, name: nil) }
      let(:html) { /<ul class="inline-errors"><li>[^<]*<\/li><\/ul>/ }
      it { is_expected.to match html }
    end
  end

  describe 'FormBuilder#error_messages_for' do
    let(:participant) { FactoryGirl.build(:participant, name: nil) }
    before { participant.validate }

    it 'calls error_messages_for' do
      expect(helper)
        .to receive(:error_messages_for)
        .with(participant, :name)
        .and_return("")

      helper.form_for(participant, url: "/") do |form|
        concat form.error_messages_for(:name)
      end
    end
  end
end
