Then(/^I should be logged in$/) do
  within(:css, ".top-navigation") do
    expect(page).to have_content(/Log out/i)
  end
end
