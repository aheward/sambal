@pending
Feature: Manage SOC

As Central Administrator, I want to process delivery logistics requests for all Activity Offerings within a selected Term
so that delivery logistics can be assigned (Mass Scheduling Event)

  Background:
    Given I am logged in as admin


  Scenario: Lock the SOC
    Given the SOC is valid for "Lock"
    When I "Lock" the SOC
    Then I verify that "Schedule" button is there for next action


  Scenario: Send AOs to the scheduler for a term
    Given the SOC is valid for "Schedule"
    When I "Schedule" the SOC
    Then I verify that "FinalEdit" button is there for next action


  Scenario: Process the SOC for Final Edit
    Given the SOC is valid for "FinalEdit"
    When I "FinalEdit" the SOC
    Then I verify that "Publish" button is there for next action


  Scenario: Publish the SOC for a term
    Given the SOC is valid for "Publish"
    When I "Publish" the SOC
    Then I verify that "Close" button is there for next action


