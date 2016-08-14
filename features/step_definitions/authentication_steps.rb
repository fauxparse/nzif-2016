Given(/^I am logged in$/) do
  visit(login_path)
  fill_in("Email", with: participant_email)
  fill_in("Password", with: password)
  click_button("Log in")
end

When(/^I enter my signup details$/) do
  fill_in("Name", with: participant_name)
  fill_in("Email", with: participant_email)
  fill_in("Password (8 characters minimum)", with: password)
  fill_in("Password confirmation", with: password)
end

Then(/^I should be logged in$/) do
  within(:css, "body > nav") do
    expect(page).not_to have_content(/Log in/i)
  end
end
