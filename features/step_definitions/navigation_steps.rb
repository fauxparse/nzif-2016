Given(/^I am on the homepage$/) do
  visit root_url
end

When(/^I click the "([^"]*)" link$/) do |link_text|
  click_link link_text
end

Then(/^I should be on the homepage$/) do
  expect(page.current_path).to eq root_path
end
