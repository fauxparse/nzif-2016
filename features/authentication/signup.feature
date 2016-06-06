Feature: Sign up for the site
  In order to use the site
  As a new user
  I want to sign up for an account

  Scenario: Successful signup
    Given I am on the homepage
     When I click the "Log in" link
      And I click the "Sign up" link
      And I enter my signup details
      And I click the "Sign up" button
     Then I should be on the homepage
      And I should be logged in
      And I should exist as a participant
