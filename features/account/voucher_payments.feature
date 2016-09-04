@javascript
Feature: Voucher payments
  As a festival volunteer
  I want to pay for my registration with a voucher
  So that I can be rewarded for the work I do for the festival

  Scenario: Whole registration paid with a voucher
    Given there is a 2016 festival
      And it is the week before the festival
      And I am an existing participant
      And there is a $500 voucher on my account
      And I am on the festival homepage
      And it is the week before the festival
     When I click the registration link
      And I enter my registration details
      And I select some initial activities
      And I accept the Code of Conduct
      And I go to my account page
     Then I should see a $500 voucher on my account
      And I should see that I have nothing left to pay

  Scenario: Registration partially paid with a voucher
    Given there is a 2016 festival
      And it is the week before the festival
      And I am an existing participant
      And there is a $200 voucher on my account
     When I register for the festival
      And I go to my account page
     Then I should see a $200 voucher on my account
      And I should see that I have $300 left to pay
