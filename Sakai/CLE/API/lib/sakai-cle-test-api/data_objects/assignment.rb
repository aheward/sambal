class AssignmentObject

  include PageHelper
  include Utilities
  include Workflows

  attr_accessor :title, :site, :instructions, :id, :link, :status, :grade_scale,
                :max_points, :allow_resubmission, :num_resubmissions

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        :title=>random_alphanums,
        :instructions=>random_multiline(250, 10, :string)
    }
    options = defaults.merge(opts)

    @title=options[:title]
    @instructions=options[:instructions]
    @site=options[:site]
    @grade_scale=options[:grade_scale]
    @max_points=options[:max_points]
    @allow_resubmission=options[:allow_resubmission]
    @num_resubmissions=options[:num_resubmissions]
    raise "You must specify a Site for your Assignment" if @site==nil
    raise "You must specify max points if your grade scale is 'points'" if @max_points==nil && @grade_scale=="Points"
  end

  alias :name :title

  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/

    # Go to assignments page
    assignments unless @browser.title=~/Assignments$/

    on_page AssignmentsList do |list|
      list.add
    end
    on_page AssignmentAdd do |add|
      add.title.set @title
      add.instructions=@instructions
      add.grade_scale.select @grade_scale unless @grade_scale==nil
      add.max_points.set @max_points unless @max_points==nil
      add.allow_resubmission.send(@allow_resubmission) unless @allow_resubmission==nil
      add.num_resubmissions.select @num_resubmissions unless @num_resubmissions==nil
      add.post
    end
    on_page AssignmentsList do |list|
      @id = list.get_assignment_id @title
      @link = list.assignment_href @title
      @status = list.status_of @title
    end
  end

  def edit opts={}
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    assignments unless @browser.title=~/Assignments$/
    on AssignmentsList do |list|
      if @status=="Draft"
        list.edit_assignment "Draft - #{@title}"
      else
        list.edit_assignment @title
      end
    end
    on AssignmentAdd do |edit|
      edit.title.set opts[:title] unless opts[:title] == nil
      unless opts[:instructions] == nil
        edit.enter_source_text edit.editor, opts[:instructions]
      end
      edit.post
    end
    @title=opts[:title] unless opts[:title] == nil
    @instructions=opts[:instructions] unless opts[:instructions] == nil
    @max_points=opts[:max_points] unless opts[:title] == nil
    on AssignmentsList do |list|
      @status=list.status_of @title
    end
  end

  def get_assignment_info
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    assignments unless @browser.title=~/Assignments$/
    on AssignmentsList do |list|
      @id = list.get_assignment_id @title
      @status=list.status_of @title
      @link=list.assignment_href @title
      if @status=="Draft"
        list.open_assignment "Draft - #{@title}"
      else
        list.edit_assignment @title
      end
    end
    on AssignmentAdd do |edit|
      # TODO: Need to add more stuff here as needed...
      @instructions=edit.get_source_text edit.editor
    end
  end

end