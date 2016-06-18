require 'rspec/expectations'

RSpec::Matchers.define :accept do |value|
  match do |subject|
    subject.accepts?(value)
  end

  failure_message do |subject|
    "expected #{subject} to accept #{value}, but it did not"
  end
end
