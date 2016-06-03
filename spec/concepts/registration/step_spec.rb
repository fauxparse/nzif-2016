require 'rails_helper'

describe Registration::Step do
  subject(:step) { Registration::Step.new(registration) }
  let(:registration) { double("Registration") }

  it { is_expected.not_to be_complete }
end
