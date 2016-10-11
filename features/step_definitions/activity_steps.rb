Given(/^there is a workshop called "([^"]*)"$/) do |name|
  @workshop = create_workshop(name)
end

When(/^I select the "([^"]*)" workshop$/) do |name|
  workshop = find_workshop_by_name(name)
  schedule = workshop.schedules.first

  within(:css, "[data-id=\"#{schedule.id}\"]") do
    expect(page).not_to have_css('input[type="checkbox"]:disabled')
    find("label").trigger("click")
  end
end

When(/^the "([^"]*)" workshop becomes unavailable$/) do |name|
  workshop = find_workshop_by_name(name)
  schedule = workshop.schedules.first
  schedule.update(maximum: 1)

  somebody_else = FactoryGirl.create(:registration, festival: festival)
  somebody_else.selections.create(schedule: schedule)
end

Then(/^I should see that the "([^"]*)" workshop is unavailable$/) do |name|
  within(:css, ".dialog") do
    expect(page).to have_content("sorry")
    expect(page).to have_content(name)
  end
end
