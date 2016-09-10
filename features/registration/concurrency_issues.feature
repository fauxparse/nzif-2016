@javascript
Feature: Handle concurrency issues during registration
  As an improvisor
  I want to know when the activities I have selected become unavailable during registration
  So that I can avoid confusion

  Scenario: Snaked!
    Given there is a 2016 festival
      And I am on the festival homepage
      And there is a workshop called "Snaked"
     When I click the registration link
      And I enter my registration details
      And I select the "Snaked" workshop
      And the "Snaked" workshop becomes unavailable
      And I click the "Continue" button
     Then I should see that the "Snaked" workshop is unavailable
