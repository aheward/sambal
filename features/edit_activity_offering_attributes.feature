@wip
Feature: Edit Activity Offering Attributes

  Background:
    Given I am logged in as admin
    Given I manage a given Course Offering
    Given I edit an Activity Offering

  Scenario: Edit Activity Offering Information attributes
    When I change Activity Offering Information attributes
    Then I am able to submit the changes
    And verify that the changes of Information attributes have persisted

  Scenario: Edit Activity Offering Requested Delivery Logistics
    When I change Requested Delivery Logistics
    Then I am able to submit the changes
    And verify that the changes of ADL have persisted

  Scenario: Edit Activity Offering Personnel attributes
    When I change Personnel attributes
    Then I am able to submit the changes
    And verify that the changes of the Personnel attributes have persisted

  Scenario: Edit Miscellaneous Activity Offering attributes
    When I change Miscellaneous Activity Offering attributes
    Then I am able to submit the changes
    And verify that the changes of Miscellaneous have persisted