When(/^I click the registration link$/) do
  click_link "Register now"
end

When(/^I enter my registration details$/) do
  within(:css, ".new-user") do
    fill_in("Name", with: participant_name)
    fill_in("Email", with: participant_email)
    fill_in("Password", with: password)
    fill_in("Password confirmation", with: password)
  end
end

When(/^I enter my name$/) do
  within(:css, ".new-user") do
    fill_in("Name", with: participant_name)
  end
end

When(/^I enter my existing registration details$/) do
  within(:css, ".existing-user") do
    fill_in("Email", with: participant_email)
    fill_in("Password", with: password)
  end
end

When(/^I select the "([^"]*)" package$/) do |package|
  choose(package)
end

Then(/^I should receive an email confirming my registration$/) do
  expect(unread_emails_for(participant_email).size).to eq 1
end

Then(/^I should be on my registration details page$/) do
  expect(page.current_path).to eq registration_path(@festival)
end

Then(/^I should be on the registration page$/) do
  expect(page.current_path).to match /^#{register_path(@festival)}(\/login)?$/
end
