class AssignmentObject

  include PageHelper
  include Utilities
  include Randomizers
  include DateMakers
  include Workflows

  attr_accessor :title, :site, :instructions, :id, :link, :status, :grade_scale,
                :max_points, :allow_resubmission, :num_resubmissions,
                :open,
                :due,
                :accept_until,
                :student_submissions,
                :resubmission,
                :add_due_date,
                # Note the following variables are taken from the Entity picker's
                # Item Info list
                :retract_time, :time_due, :time_modified, :url, :portal_url,
                :description, :time_created, :direct_url

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
    @open=options[:open]
    @due=options[:due]
    @accept_until=options[:accept_until]
    @resubmission=options[:resubmission]
    @student_submissions=options[:student_submissions]
    @add_due_date=options[:add_due_date]
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
      @grade_scale==nil ? @grade_scale=add.grade_scale.value : add.grade_scale.select(@grade_scale)
      @open[:MON]==nil ? @open[:MON]=add.open_month.value : add.open_month.select(@open[:MON])
      add.max_points.set(@max_points) unless @max_points==nil
      @open[:year]==nil ? @open[:year]=add.open_year.value : add.open_year.select(@open[:year])
      @open[:day_of_month]==nil ? @open[:day_of_month]=add.open_day.value : add.open_day.select(@open[:day_of_month])
      @open[:hour]==nil ? @open[:hour]=add.open_hour.value : add.open_hour.select(@open[:hour])
      @open[:minute]==nil ? @open[:minute]=add.open_minute.value : add.open_minute.select(@open[:minute])
      @open[:MERIDIAN]==nil ? @open[:MERIDIAN]=add.open_meridian.value : add.open_meridian.select(@open[:MERIDIAN])
      @allow_resubmission==nil ? @allow_resubmission=checkbox_setting(add.allow_resubmission) : add.allow_resubmission.send(@allow_resubmission)
      @add_due_date==nil ? @add_due_date=checkbox_setting(add.add_due_date) : add.add_due_date.send(@add_due_date)
      # TODO: Add Due and Accept dates here
      if @allow_resubmission==:set
        @num_resubmissions==nil ? @num_resubmissions=add.num_resubmissions.value : add.num_resubmissions.select(@num_resubmissions)
        @student_submissions==nil ? @student_submissions=add.student_submissions.value : add.student_submissions.select(@student_submissions)
        @resubmission[:MON]==nil ? @resubmission[:MON]=add.resub_until_month.value : add.resub_until_month.select(@resubmission[:MON])
        @resubmission[:day_of_month]==nil ? @resubmission[:day_of_month]=add.resub_until_day.value : add.select(@resubmission[:day_of_month])
        @resubmission[:year]==nil ? @resubmission[:year]=add.resub_until_year.value : add.select(@resubmission[:year])
        @resubmission[:hour]==nil ? @resubmission[:hour]=add.resub_until_hour.value : add.select(@resubmission[:hour])
        @resubmission[:minute]==nil ? @resubmission[:minute]=add.resub_until_minute.value : add.select(@resubmission[:minute])
        @resubmission[:MERIDIAN]==nil ? @resubmission[:MERIDIAN]=add.resub_until_meridian.value : add.select(@resubmission[:MERIDIAN])
      end
      #@do_not_add_to_gradebook==nil ? @do_not_add_to_gradebook=radio_setting(add.do_not_add_gradebook.set?) :
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
    # TODO: Add all the rest of the elements here
    on AssignmentsList do |list|
      @status=list.status_of @title
    end
  end

  def get_info
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

    # TODO: Need to add more stuff here as needed...

    on AssignmentAdd do |edit|

      @instructions=edit.get_source_text edit.editor
      edit.source edit.editor
      edit.entity_picker(edit.editor)
    end
    on EntityPicker do |info|
      info.view_assignment_details @title
      @retract_time=info.retract_time
      @time_due=info.time_due
      @time_modified=info.time_modified
      @url=info.url
      @portal_url=info.portal_url
      @description=info.description
      @time_created=info.time_created
      @direct_url=info.direct_link
      info.close_picker
    end
    on AssignmentAdd do |edit|
      edit.cancel
    end
  end

end