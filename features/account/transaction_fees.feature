@javascript
Feature: Transaction fees
  As a festival participant
  I want to see transaction fees in my account summary
  So that I can understand what I am being charged

  Scenario: Internet banking fees
    Given there is a 2016 festival
      And there is a $2 fee on Internet banking transactions
      And I am on the festival homepage
      And it is the week before the festival
     When I click the registration link
      And I enter my registration details
      And I select some initial activities
      And I accept the Code of Conduct
      And I choose to pay by Internet banking
      And I go to my account page
     Then I should see that my total due is $500
      And I should see a pending Internet banking payment of $502
      And I should see an Internet banking fee of $2
      And I should see that my outstanding total is $500
