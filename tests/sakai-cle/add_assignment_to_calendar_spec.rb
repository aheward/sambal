require 'rspec'
require 'sakai-cle-test-api'
require 'yaml'

describe "Assignment Due Date on Calendar" do

  include Utilities
  include Workflows
  include PageHelper
  include Randomizers
  include DateMakers

  before :all do

    # Get the test configuration data
    @config = YAML.load_file("config.yml")
    @directory = YAML.load_file("directory.yml")
    @sakai = SakaiCLE.new(@config['browser'], @config['url'])
    @browser = @sakai.browser

    @student = @directory['person1']['id']
    @spassword = @directory['person1']['password']
    @instructor1 = @directory['person3']['id']
    @ipassword = @directory['person3']['password']

    @instructor2 = @directory['person4']['id']
    @password1 = @directory['person4']['password']

    @sakai.page.login(@instructor1, @ipassword)

    @site = make SiteObject
    @site.create

    @site.add_official_participants :role=>"Student", :participants=>[@student]
    @site.add_official_participants :role=>"Instructor", :participants=>[@instructor2]

    @assignment1 = make AssignmentObject, :site=>@site.name, :title=>random_string, :grade_scale=>"Letter grade", :instructions=>random_multiline(500, 10, :string), :open=>minutes_ago(5)
    @assignment2 = make AssignmentObject, :allow_resubmission=>:set, :add_due_date=>:set, :site=>@site.name, :title=>random_nicelink(15), :open=>hours_ago(5), :student_submissions=>"Inline only", :grade_scale=>"Letter grade", :instructions=>random_multiline(750, 13, :string)

    @assignment1.create
    @assignment2.create

  end

  after :all do
    # Close the browser window
    @sakai.browser.close
  end

  it "When 'add due date to schedule' not checked, Assignment does not appear on the Calendar" do
    calendar

    on Calendar do |calendar|
      # List events on the expected due date for Assignment 2
      calendar.view.select "List of Events"
      calendar.show_events.select "Custom date range"
      calendar.start_month.select @assignment1.due[:MON]
      calendar.start_day.select @assignment1.due[:day_of_month]
      calendar.start_year.select @assignment1.due[:year]
      calendar.end_month.select @assignment1.due[:MON]
      calendar.end_day.select @assignment1.due[:day_of_month]
      calendar.end_year.select @assignment1.due[:year]
      calendar.filter_events

      calendar.events_list.should_not include "Due #{@assignment1.title}"
    end
  end

  it "When 'add due date to schedule' is checked, Assignment appears on the Calendar" do
    on Calendar do |calendar|
      calendar.start_month.select @assignment2.due[:MON]
      calendar.start_day.select @assignment2.due[:day_of_month]
      calendar.start_year.select @assignment2.due[:year]
      calendar.end_month.select @assignment2.due[:MON]
      calendar.end_day.select @assignment2.due[:day_of_month]
      calendar.end_year.select @assignment2.due[:year]
      calendar.filter_events

      calendar.events_list.should include "Due #{@assignment2.title}"

    end
  end

  # TODO: Add tests for student and other instructor being able to see the assignment in the calendar

end