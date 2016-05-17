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
     Then I am on my registration details page
      And I am logged in
      And I see "registered"
      And I receive an email confirming my registration
