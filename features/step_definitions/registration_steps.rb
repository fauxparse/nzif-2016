When(/^I click the registration link$/) do
  click_link "Register now"
end

When(/^I enter my registration details$/) do
  fill_in("Name", with: "Alice")
  fill_in("Email", with: "alice@example.com")
  fill_in("Password", with: "p4$$w0rd")
  fill_in("Password confirmation", with: "p4$$w0rd")
end

Then(/^I should receive an email confirming my registration$/) do
  expect(unread_emails_for("alice@example.com").size).to eq 1
end

Then(/^I should be on my registration details page$/) do
  expect(page.current_path).to eq registration_path(@festival)
end
