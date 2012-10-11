require 'rspec'
require 'sakai-cle-test-api'
require 'yaml'

describe "Assignments" do

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

    @assignment = make AssignmentObject, :site=>@site.name, :title=>random_string(25), :open=>next_monday, :grade_scale=>"Pass", :instructions=>random_multiline(300, 15, :string)

    @assignment.create

  end

  after :all do
    # Close the browser window
    @sakai.browser.close
  end

  it "Assignments with 'Pass' gradescale cannot be added to the Gradebook" do
    @assignment.edit :status=>"Editing", :add_to_gradebook=>:set
    on AssignmentAdd do |edit|
      sleep 0.1
      edit.add_to_gradebook.should_not be_set
      edit.gradebook_warning.should be_present
    end
  end

  it "Assignments with 'Ungraded' gradescale cannot be added to the Gradebook" do
    on AssignmentAdd do |edit|
      edit.grade_scale.select "Ungraded"
      edit.add_to_gradebook.set
      sleep 0.1
      edit.add_to_gradebook.should_not be_set
      edit.gradebook_warning.should be_present
      edit.gradebook_warning.wait_while_present
    end
  end

  it "Assignments with 'Letter grade' gradescale cannot be added to the Gradebook" do
    on AssignmentAdd do |edit|
      edit.grade_scale.select "Letter grade"
      edit.add_to_gradebook.set
      sleep 0.1
      edit.add_to_gradebook.should_not be_set
      edit.gradebook_warning.should be_present
      edit.gradebook_warning.wait_while_present
    end
  end

  it "Assignments with 'Checkmark' gradescale cannot be added to the Gradebook" do
    on AssignmentAdd do |edit|
      edit.grade_scale.select "Checkmark"
      edit.add_to_gradebook.set
      sleep 0.1
      edit.add_to_gradebook.should_not be_set
      edit.gradebook_warning.should be_present
    end
  end

  it "Assignments graded by points can be added to the gradebook" do
    reset
    @assignment.edit :grade_scale=>"Points", :max_points=>"111", :add_to_gradebook=>:set
    gradebook
    on Gradebook do |book|
      book.items_titles.should include @assignment.title
    end
  end

end