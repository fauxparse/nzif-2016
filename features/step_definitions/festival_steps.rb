Given(/^there are no existing festivals$/) do
  Festival.destroy_all
end

Given(/^there is a (\d{4}) festival$/) do |year|
  @festival ||= FactoryGirl.create(:festival, year: year.to_i)
end

Given(/^I am on the festival homepage$/) do
  visit festival_path(@festival)
end

When(/^I visit the homepage$/) do
  visit root_path
end

Then(/^I should be redirected to the (\d{4}) festival page$/) do |year|
  expect(page.current_path).to eq "/#{year}"
end
