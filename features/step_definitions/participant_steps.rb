Given(/^I am an existing participant who has never logged in$/) do
  create_participant
end

Given(/^I am an existing user$/) do
  create_participant(true)
end

Given(/^I am an existing user without a participant$/) do
  create_user
end

Then(/^there should be only one participant with my details$/) do
  expect(Participant.where(name: participant_name).count).to eq 1
end
