# Helper methods that don't properly belong elsewhere. This is
# a sort of "catch all" Module.
module Workflows

  # Site Navigation helpers...
  def go_to_rollover_details
    enrollment
    on(Enrollment).view_rollover_details
  end

  def go_to_perform_rollover
    enrollment
    on(Enrollment).perform_rollover
  end

  def go_to_create_population
    enrollment
    on(Enrollment).manage_populations
    on(ManagePopulations).create_new
  end

  def go_to_manage_population
    enrollment
    on(Enrollment).manage_populations
  end

  def go_to_manage_reg_windows
    enrollment
    on(Enrollment).manage_registration_windows
  end

  def go_to_manage_course_offerings
    enrollment
    on(Enrollment).manage_course_offerings
  end

  def go_to_display_schedule_of_classes
    enrollment
    on(Enrollment).schedule_of_classes
  end

  def go_to_holiday_calendar
    enrollment
    on(Enrollment).create_holiday_calendar
  end

  def go_to_academic_calendar
    enrollment
    on(Enrollment).create_academic_calendar
  end

  def go_to_calendar_search
    enrollment
    on(Enrollment).search_for_calendar_or_term
  end

  def go_to_create_course_offerings
    enrollment
    on(Enrollment).create_course_offerings
  end

  def go_to_manage_soc
    enrollment
    on(Enrollment).manage_soc
  end

  def enrollment
    visit(MainMenu).enrollment_home
  end

  def logged_in_user
    user = ""
    on Header do |page|
      begin
        user = page.logged_in_user
      rescue Watir::Exception::UnknownObjectException
        user = "No One"
      end
    end
    user
  end

  def log_in(user, pwd)
    on(Login).login_with user, pwd
  end

end