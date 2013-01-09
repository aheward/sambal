Given /^the SOC is valid for "(.*?)"$/ do |currentState|
  @manageSoc = make ManageSoc
  @manageSoc.search
  @manageSoc.check_state_change_button_exists currentState
end

When /^I "(.*?)" the SOC$/ do |newState|
  @manageSoc.change_action newState
end

Then /^I verify that "(.*?)" button is there for next action$/ do |nextState|
  @manageSoc.check_state_change_button_exists nextState
end