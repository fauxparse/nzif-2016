Feature: Register for an event
  In order to take part in NZIF
  As an improvisor
  I want to register for the festival

  Scenario: Successful registration
    Given there is a 2016 festival
      And I am on the festival homepage
     When I click the registration link
      And I enter my registration details
      And I click the "Continue" button
     Then I should be on my registration details page
      And I should be logged in
      And I should see "registered"
      And I should receive an email confirming my registration
