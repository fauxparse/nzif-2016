Given(/^I am an existing participant who has never logged in$/) do
  FactoryGirl.create(:participant, name: "Alice", email: "alice@example.com")
end

Given(/^I am an existing user$/) do
  FactoryGirl.create(
    :participant,
    name: "Alice",
    user: FactoryGirl.create(:user, email: "alice@example.com")
  )
end

Given(/^I am an existing user without a participant$/) do
  FactoryGirl.create(:user, email: "alice@example.com")
end

Then(/^there should be only one participant with my details$/) do
  expect(Participant.where(name: "Alice").count).to eq 1
end
