When(/^I click the "([^"]*)" button$/) do |button_text|
  click_button(button_text)
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content(/#{text}/i)
end
