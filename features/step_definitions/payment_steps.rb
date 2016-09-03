Then(/^I should see instructions for paying by Internet banking$/) do
  expect(page).to have_content bank_account_name
  expect(page).to have_content bank_account_number
end
