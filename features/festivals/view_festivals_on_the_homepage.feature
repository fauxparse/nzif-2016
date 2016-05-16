Feature: View the current festival on the homepage
  In order to see information about the festival
  As an improvisor
  I want to see festival dates on the homepage

  Scenario: No existing festivals
    Given there are no existing festivals
     When I visit the homepage
     Then I should see "check back later"

  Scenario: A current festival
    Given there is a 2016 festival
     When I visit the homepage
     Then I should be redirected to the 2016 festival page
      And I should see "NZIF 2016"
      And I should see "4–8 October, 2016"
