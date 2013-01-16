#Scenario: Edit Activity Offering Information attributes
When /^I change Activity Offering Information attributes$/ do
  # Activity Code can not be saved. This is a bug
  # Modify Total Maximum Enrollment to 100
  #$total_maximum_enrollment = 88
  #on ActivityOfferingMaintenance do |page|
  #  $orig_enroll = page.total_maximum_enrollment.value.to_i
  #  page.total_maximum_enrollment.set $total_maximum_enrollment
  #  page.total_maximum_enrollment.fire_event "onchange"
  #end
end

Then /^I am able to submit the changes$/ do
  #on ActivityOfferingMaintenance do |page|
  #  page.submit
  #end
end


And /^verify that the changes of Information attributes have persisted$/ do
  #goto_manage_co
  #goto_edit_ao
  #sleep 6
  #on ActivityOfferingMaintenance do |page|
  #  page.total_maximum_enrollment.value.to_i.should == $total_maximum_enrollment
  #  # clean up
  #  page.total_maximum_enrollment.set $orig_enroll
  #  page.total_maximum_enrollment.fire_event "onchange"
  #  page.submit
  #end
end

#Scenario: Edit Activity Offering Requested Delivery Logistics
When /^I change Requested Delivery Logistics$/ do
#  Facility code: ccc and room 1105  or CHM  and 124
end

And /^verify that the changes of ADL have persisted$/ do
#pending # express the regexp above with the code you wish you had
end


  #Scenario: Edit Activity Offering Personnel attributes
  When /^I change Personnel attributes$/ do
    # H.ERICD, admin are ids can be used.
    # These line should be moved to a step definition that says:
    # "Given I have a teaching assistant". They are not appropriate in this
    # step definition, which is specifically about CHANGING
    # the attributes of something that already exists.
    @teaching_assistant = make Personnel
    @teaching_assistant.create
    #page.add_person_id.set  @added_person_id
    #page.add_affiliation.select("Teaching Assistant")
    #page.add_inst_effort.set @effort_num
    #page.add_personnel

    # This should be the entirety of this step definition:
    @teaching_assistant.edit id: @added_person_id, affiliation: "Teaching Assistant", inst_effort: @effort_num
  end

And /^verify that the changes of the Personnel attributes have persisted$/ do
  @course_offering.manage
  @course_offering.edit_ao :ao_code =>  @orig_ao_code
  sleep 30
  on ActivityOfferingMaintenance do |page|
    page.delete_id(@added_person_id)
    page.submit
  end
end

#Scenario: Edit Miscellaneous Activity Offering attributes
When /^I change Miscellaneous Activity Offering attributes$/ do
#  pending # express the regexp above with the code you wish you had
end

And /^verify that the changes of Miscellaneous have persisted$/ do
#pending # express the regexp above with the code you wish you had
end

Given /^I manage a given Course Offering$/ do
  @course_offering = make CourseOffering, :course=>"ENGL105"
  @course_offering.manage
end

Given /^I edit an Activity Offering$/ do
  @total_number = @course_offering.ao_list.count
  @orig_ao_code = @course_offering.ao_list[@total_number-1]
  @added_person_id = "admin"
  @effort_num = 30
  @course_offering.edit_ao :ao_code =>  @orig_ao_code
end
