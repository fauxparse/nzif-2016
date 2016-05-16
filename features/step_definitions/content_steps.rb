When(/^I click the "([^"]*)" button$/) do |arg1|
  pending # Write code here that turns the phrase above into concrete actions
end

Then(/^I see "([^"]*)"$/) do |text|
  expect(page).to have_content(/#{text}/i)
end
