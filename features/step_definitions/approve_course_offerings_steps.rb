When /^I create two new Course Offerings$/ do
  # This explicit definition of @course_code is unnecessary
  # because the value is kept in the data object as:
  # @course_offering.course
  #@course_code="CHEM142" <- removed as redundant, see line 33
  @course_offering = make CourseOffering, :course=>"CHEM142" # <=explicitly including this in the make for the the data object

  # Given that this step definition is about "creating" course offerings,
  # I have to wonder what this stuff is.
  # If it's part of creating a course then it should probably be folded
  # into the .create method for course offering objects.
  #
  # However, if it's extra, then its purpose should
  # be explicitly stated in the feature and the corresponding
  # step definition.
  @course_offering.search_by_coursecode
  on ManageCourseOfferings do |page|
    # if this course offering list is an aspect of the course offering data object then
    # there needs to be some serious reworking of the data object definitions surrounding Course Offerings.
    # I discussed this with Chong. There probably needs to be some nested Data Objects
    # created. That should simplify the code at the step definition level, and keep
    # things cleaner in general.
    # What I mean is, this should probably look like: @course_offering.co_list, instead.
    @orig_co_list = []
    page.codes_list.each { |code| @orig_co_list << code }
  end

  go_to_create_course_offerings

  # This is a creation from an existing Course Offering, which
  # to a neophyte user of the system seems to not be what the
  # step definition is about. Should the feature verbiage be changed to
  # "I create course offerings from existing course offerings?"
  on(CreateCourseOffering).create_co_from_existing "20122", @course_offering.course # <= updated to use data object

  # You're using the same instance variable name for your second Course Offering!
  # This overwrites your previous data object!!!!
  # I'm updating this variable name because the step says you're
  # creating TWO course offerings, not creating one and then editing it...
  @course_offering2 = make CourseOffering, :course=>@course_code
  # To repeat: If this is part of the "create" step then it should
  # be moved to the data object's create method...
  @course_offering2.search_by_coursecode
  on ManageCourseOfferings do |page|
    # As I said above, this probably needs to be fixed to become @course_offering2
    @new_co_list = @orig_co_list.to_set ^ page.codes_list.to_set
  end
end

And /^I add Activity Offerings to the new Course Offerings$/ do
  # Not sure what this line is for.
  @course_code=@new_co_list.to_a[0]
  # Why are you remaking the @course_offering object again????
  # Is this supposed to be a THIRD course offering object????
  # These steps are not making any sense to me based on what the
  # step definition says should be happening.
  @course_offering = make CourseOffering, :course=>@course_code
  @course_offering.search_by_coursecode
  on ManageCourseOfferings do |page|
    format = page.format.options[1].text
    page.add_ao format, 2
  end
end

And /^I approve the subject code for scheduling$/ do
  # Yet again you are overwriting the @course_offering object with a make!!!
  @course_offering = make CourseOffering, :course=>@course_code
  @course_offering.search_by_subjectcode

  on ManageCourseOfferingList do  |page|
    begin
      page.approve_subject_code_for_scheduling
      #page.driver.wait_until(page.driver.browser.switch_to.alert.dismiss)
    rescue Selenium::WebDriver::Error::UnhandledAlertError
      #page.driver.wait_until(page.driver.browser.switch_to.alert.dismiss)
    page.approve_subject_code_for_scheduling
      end
  end
end

When /^I manage a Course Offering$/ do
  @course_code="CHEM317"
  # Another make???
  @course_offering = make CourseOffering, :course=>@course_code
  @course_offering.manage
end

And /^I add Activity Offerings to the Course Offering$/ do
  on ManageCourseOfferings do |page|
    format = page.format.options[1].text
    page.add_ao format, 2
  end
end

And /^I approve the Course Offering for scheduling$/ do
  # Another make???
  @course_offering = make CourseOffering, :course=>@course_code
  @course_offering.search_by_subjectcode
  on ManageCourseOfferingList do |page|
    page.select_cos([@course_code])
    page.selected_offering_actions.select("Approve for Scheduling")
    page.go
  end
end

And /^I approve selected Activity Offerings for scheduling$/ do
  on ManageCourseOfferings do |page|
    @new_ao_list = @course_offering.ao_list.to_set ^ page.codes_list.to_set
    page.select_aos(@new_ao_list)
    page.selected_offering_actions.select("Approve for Scheduling")
    page.go
    page.a
  end
end

Then /^the Activity Offerings should be in Approved state$/ do
  # Another make???  This is completely invalidating all prior steps
  # in the scenario!
  @course_offering = make CourseOffering, :course=>@course_code
  @course_offering.manage

  on ManageCourseOfferings do |page|
    for code in page.codes_list
      page.ao_status(code, "Approved").should == true
    end
  end
end

Then /^the selected Activity Offerings should be in Approved state$/ do
  on ManageCourseOfferings do |page|
    for code in @new_ao_list
      page.ao_status(code, "Approved").should == true
    end
  end
end