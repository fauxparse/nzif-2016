Given(/^I am logged in$/) do
  visit(login_path)
  fill_in("Email", with: participant_email)
  fill_in("Password", with: password)
  click_button("Log in")
end

Then(/^I should be logged in$/) do
  within(:css, "body > nav") do
    expect(page).to have_content(/Log out/i)
  end
end
