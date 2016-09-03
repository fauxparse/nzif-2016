Given(/^there is a \$(\d+) fee on Internet banking transactions$/) do |fee|
  PaymentMethod::Configuration::InternetBankingConfiguration
    .first.update!(transaction_fee: fee.to_i)
end

When(/^I go to my account page$/) do
  visit(account_path(festival))
end

Then(/^I should see that my total due is (\$\d+)$/) do |total|
  within(:css, ".subtotal.total-due") do
    expect(page).to have_content(total)
  end
end

Then(/^I should see a pending Internet banking payment of (\$\d+)$/) do |amount|
  within(:css, ".payment") do
    expect(page).to have_content(amount)
  end
end

Then(/^I should see an Internet banking fee of (\$\d+)$/) do |fee|
  within(:css, ".payment small") do
    expect(page).to have_content("Includes Internet banking fee of #{fee}")
  end
end

Then(/^I should see that my outstanding total is (\$\d+)$/) do |total|
  within(:css, ".total") do
    expect(page).to have_content(total)
  end
end

