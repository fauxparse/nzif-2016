Given(/^there is a \$(\d+) fee on Internet banking transactions$/) do |fee|
  PaymentMethod::Configuration::InternetBankingConfiguration
    .first.update!(transaction_fee: fee.to_i)
end

Given(/^there is a \$(\d+(?:\.\d{2})?) voucher on my account$/) do |amount|
  Voucher.create!(
    amount: amount,
    festival: festival,
    participant: participant,
    admin: admin,
    reason: "Thanks!"
  )
end

When(/^I go to my account page$/) do
  visit(account_path(festival))
end

Then(/^I should see that my total due is (\$\d+)$/) do |total|
  within(:css, ".subtotal.total-due") do
    expect(page).to have_content(total)
  end
end

Then(/^I should see that I have nothing left to pay$/) do
  step "I should see that I have $0 left to pay"
end

Then(/^I should see that I have \$(\d+(?:\.\d{2})?) left to pay$/) do |amount|
  within(:css, ".total") do
    expect(page).to have_content(amount)
  end
end

Then(/^I should see a pending Internet banking payment of (\$\d+(?:\.\d{2})?)$/) do |amount|
  within(:css, ".payment") do
    expect(page).to have_content(amount)
  end
end

Then(/^I should see an Internet banking fee of (\$\d+(?:\.\d{2})?)$/) do |fee|
  within(:css, ".payment small") do
    expect(page).to have_content("Includes Internet banking fee of #{fee}")
  end
end

Then(/^I should see that my outstanding total is (\$\d+(?:\.\d{2})?)$/) do |total|
  within(:css, ".total") do
    expect(page).to have_content(total)
  end
end

Then(/^I should see a \$(\d+) voucher on my account$/) do |amount|
  expect(Participant.count).to eq 1
  expect(Voucher.last.festival).to eq(Registration.last.festival)
  expect(Account.new(Registration.last).vouchers.size).to eq(1)
  within(:css, ".voucher") do
    expect(page).to have_content(amount)
  end
end
