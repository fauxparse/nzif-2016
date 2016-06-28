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
      And I select the "Medium" package
      And I click the "Continue" button
      And I click the "Pay by Internet banking" button
     Then I should be on my registration details page
      And I should be logged in
      And I should see "registered"
      And I should receive an email confirming my registration

  Scenario: Unsuccessful registration
    Given there is a 2016 festival
      And I am on the festival homepage
     When I click the registration link
      And I click the "Continue" button
     Then I should be on the registration page
      And I should see "Name can't be blank"
      And I should see "Email can't be blank"

  Scenario: Registration with existing participant
    Given I am an existing participant who has never logged in
      And there is a 2016 festival
      And I am on the festival homepage
     When I click the registration link
      And I enter my registration details
      And I click the "Continue" button
      And I select the "Medium" package
      And I click the "Continue" button
      And I click the "Pay by Internet banking" button
     Then I should be on my registration details page
      And I should be logged in
      And I should see "registered"
      And I should receive an email confirming my registration
      And there should be only one participant with my details

  Scenario: Registration with existing user
    Given I am an existing user
      And there is a 2016 festival
      And I am on the festival homepage
     When I click the registration link
      And I enter my existing registration details
      And I click the "Log in" button
      And I click the "Continue" button
      And I select the "Medium" package
      And I click the "Continue" button
      And I click the "Pay by Internet banking" button
     Then I should be on my registration details page
      And I should be logged in
      And I should see "registered"
      And I should receive an email confirming my registration
      And there should be only one participant with my details

  Scenario: Registration with existing user without a participant
    Given I am an existing user without a participant
      And I am logged in
      And there is a 2016 festival
      And I am on the festival homepage
     When I click the registration link
      And I enter my name
      And I click the "Continue" button
      And I select the "Medium" package
      And I click the "Continue" button
      And I click the "Pay by Internet banking" button
     Then I should be on my registration details page
      And I should be logged in
      And I should see "registered"
      And I should receive an email confirming my registration
      And there should be only one participant with my details

  Scenario: Registration attempt with bad login
    Given there is a 2016 festival
      And I am on the festival homepage
     When I click the registration link
      And I enter my existing registration details
      And I click the "Log in" button
     Then I should be on the registration page
      And I should see "Email doesn’t match password"
