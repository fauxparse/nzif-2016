When(/^I click the registration link$/) do
  click_link "Register now"
end

When(/^I enter my registration details$/) do
  fill_in("Name", with: "Alice")
  fill_in("Email", with: "alice@example.com")
  fill_in("Password", with: "p4$$w0rd")
  fill_in("Password confirmation", with: "p4$$w0rd")
end

Then(/^I receive an email confirming my registration$/) do
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I am on my registration details page$/) do
  expect(page.current_path).to eq registration_path(@festival)
end

