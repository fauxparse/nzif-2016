Given(/^there are no existing festivals$/) do
  Festival.destroy_all
end

Given(/^there is a (\d{4}) festival$/) do |year|
  expect(festival(year.to_i)).not_to be_nil
end

Given(/^I am on the festival homepage$/) do
  visit festival_path(festival)
end

When(/^I visit the homepage$/) do
  visit root_path
end

Then(/^I should be redirected to the (\d{4}) festival page$/) do |year|
  expect(page.current_path).to eq "/#{year}"
end

Then(/^I should be on the festival homepage$/) do
  expect(page.current_path).to eq festival_path(festival)
end
