require 'rspec'
require 'sakai-cle-test-api'
require 'yaml'

describe "Assignments appearing in Announcements" do

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

    @assignment1 = make AssignmentObject, :status=>"Draft", :add_open_announcement=>:set, :site=>@site.name, :title=>random_xss_string(30), :open=>in_an_hour, :student_submissions=>"Attachments only", :grade_scale=>"Points", :max_points=>"100", :instructions=>random_multiline(600, 12, :string)
    @assignment2 = make AssignmentObject, :site=>@site.name, :add_open_announcement=>:set, :open=>an_hour_ago
    @assignment1.create
    @assignment2.create

  end

  after :all do
    # Close the browser window
    @sakai.browser.close
  end

  it "Assignments in Draft status do not appear in Announcements" do
    home

    on Home do |home|
     home.announcements_list.should_not include("Assignment: Open Date for '#{@assignment1.title}'")
    end
  end

  it "Open assignments do appear in Announcements" do
    on Home do |home|
      home.announcements_list.should include("Assignment: Open Date for '#{@assignment2.title}'")
    end
  end

  it "Changing assignment from Draft to open will display assignment in Announcements" do
    @assignment1.edit :status=>"Open"
    home
    on Home do |home|
      home.announcements_list.should include("Assignment: Open Date for '#{@assignment1.title}'")
    end
  end

end