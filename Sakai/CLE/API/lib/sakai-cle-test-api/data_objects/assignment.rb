class AssignmentObject

  include PageHelper
  include Utilities
  include Randomizers
  include DateMakers
  include Workflows

  attr_accessor :title, :site, :instructions, :id, :link, :status, :grade_scale,
                :max_points, :allow_resubmission, :num_resubmissions, :open,
                :due, :accept_until, :student_submissions, :resubmission,
                :add_due_date, :add_open_announcement, :add_to_gradebook,
                # Note the following variables are taken from the Entity picker's
                # Item Info list
                :retract_time, :time_due, :time_modified, :url, :portal_url,
                :description, :time_created, :direct_url

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        :title=>random_alphanums,
        :instructions=>random_multiline(250, 10, :string),
        :resubmission=>{},
        :open=>{},
        :due=>{},
        :accept_until=>{}
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
    @add_open_announcement=options[:add_open_announcement]
    @add_to_gradebook=options[:add_to_gradebook]
    @status=options[:status]
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
      @allow_resubmission==nil ? @allow_resubmission=checkbox_setting(add.allow_resubmission) : add.allow_resubmission.send(@allow_resubmission)
      if @allow_resubmission==:set
        add.num_resubmissions.wait_until_present
        @num_resubmissions==nil ? @num_resubmissions=add.num_resubmissions.selected_options[0].text : add.num_resubmissions.select(@num_resubmissions)
        @resubmission[:MON]==nil ? @resubmission[:MON]=add.resub_until_month.selected_options[0].text : add.resub_until_month.select(@resubmission[:MON])
        @resubmission[:day_of_month]==nil ? @resubmission[:day_of_month]=add.resub_until_day.selected_options[0].text : add.select(@resubmission[:day_of_month])
        @resubmission[:year]==nil ? @resubmission[:year]=add.resub_until_year.selected_options[0].text : add.select(@resubmission[:year])
        @resubmission[:hour]==nil ? @resubmission[:hour]=add.resub_until_hour.selected_options[0].text : add.select(@resubmission[:hour])
        @resubmission[:minute_rounded]==nil ? @resubmission[:minute_rounded]=add.resub_until_minute.selected_options[0].text : add.select(@resubmission[:minute_rounded])
        @resubmission[:MERIDIAN]==nil ? @resubmission[:MERIDIAN]=add.resub_until_meridian.selected_options[0].text : add.select(@resubmission[:MERIDIAN])
      end
      add.title.set @title
      add.instructions=@instructions
      @student_submissions==nil ? @student_submissions=add.student_submissions.selected_options[0].text : add.student_submissions.select(@student_submissions)
      @grade_scale==nil ? @grade_scale=add.grade_scale.selected_options[0].text : add.grade_scale.select(@grade_scale)
      @open[:MON]==nil ? @open[:MON]=add.open_month.selected_options[0].text : add.open_month.select(@open[:MON])
      add.max_points.set(@max_points) unless @max_points==nil
      @open[:year]==nil ? @open[:year]=add.open_year.selected_options[0].text : add.open_year.select(@open[:year])
      @open[:day_of_month]==nil ? @open[:day_of_month]=add.open_day.selected_options[0].text : add.open_day.select(@open[:day_of_month])
      @open[:hour]==nil ? @open[:hour]=add.open_hour.selected_options[0].text : add.open_hour.select(@open[:hour])
      @open[:minute_rounded]==nil ? @open[:minute_rounded]=add.open_minute.selected_options[0].text : add.open_minute.select(@open[:minute_rounded])
      @open[:MERIDIAN]==nil ? @open[:MERIDIAN]=add.open_meridian.selected_options[0].text : add.open_meridian.select(@open[:MERIDIAN])
      @add_due_date==nil ? @add_due_date=checkbox_setting(add.add_due_date) : add.add_due_date.send(@add_due_date)
      @add_open_announcement==nil ? @add_open_announcement=checkbox_setting(add.add_open_announcement) : add.add_open_announcement.send(@add_open_announcement)
      @add_to_gradebook==nil ? @add_to_gradebook=radio_setting(add.add_to_gradebook) : add.add_to_gradebook.send(@add_to_gradebook)
      @due[:MON]==nil ? @due[:MON]=add.due_month.selected_options[0].text : add.due_month.select(@due[:MON])
      @due[:year]==nil ? @due[:year]=add.due_year.selected_options[0].text : add.due_year.select(@due[:year])
      @due[:day_of_month]==nil ? @due[:day_of_month]=add.due_day.selected_options[0].text : add.due_day.select(@due[:day_of_month])
      @due[:hour]==nil ? @due[:hour]=add.due_hour.selected_options[0].text : add.due_hour.select(@due[:hour])
      @due[:minute_rounded]==nil ? @due[:minute_rounded]=add.due_minute.selected_options[0].text : add.due_minute.select(@due[:minute_rounded])
      @due[:MERIDIAN]==nil ? @due[:MERIDIAN]=add.due_meridian.selected_options[0].text : add.due_meridian.select(@due[:MERIDIAN])
      @accept_until[:MON]==nil ? @accept_until[:MON]=add.accept_month.selected_options[0].text : add.accept_month.select(@accept_until[:MON])
      @accept_until[:year]==nil ? @accept_until[:year]=add.accept_year.selected_options[0].text : add.accept_year.select(@accept_until[:year])
      @accept_until[:day_of_month]==nil ? @accept_until[:day_of_month]=add.accept_day.selected_options[0].text : add.accept_day.select(@accept_until[:day_of_month])
      @accept_until[:hour]==nil ? @accept_until[:hour]=add.accept_hour.selected_options[0].text : add.accept_hour.select(@accept_until[:hour])
      @accept_until[:minute_rounded]==nil ? @accept_until[:minute_rounded]=add.accept_minute.selected_options[0].text : add.accept_minute.select(@accept_until[:minute_rounded])
      @accept_until[:MERIDIAN]==nil ? @accept_until[:MERIDIAN]=add.accept_meridian.selected_options[0].text : add.accept_meridian.select(@accept_until[:MERIDIAN])
      #@do_not_add_to_gradebook==nil ? @do_not_add_to_gradebook=radio_setting(add.do_not_add_gradebook.set?) :
      if @status=="Draft"
        add.save_draft
      else
        add.post
      end
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
      edit.title.set opts[:title] unless opts[:title]==nil
      unless opts[:instructions]==nil
        edit.enter_source_text edit.editor, opts[:instructions]
      end
      edit.grade_scale.select opts[:grade_scale] unless opts[:grade_scale]==nil
      edit.max_points.set opts[:max_points] unless opts[:max_points]==nil
      # This should be one of the last items edited...
      edit.add_to_gradebook.send(opts[:add_to_gradebook]) unless opts[:add_to_gradebook]==nil

      #TODO: All the rest goes here

      if (@status=="Draft" && opts[:status]==nil) || opts[:status]=="Draft"
        edit.save_draft
      elsif opts[:status]=="Editing"
        # Stay on the page
      else
        edit.post
      end
    end
    @title=opts[:title] unless opts[:title] == nil
    @instructions=opts[:instructions] unless opts[:instructions] == nil
    @grade_scale=opts[:grade_scale] unless opts[:grade_scale] == nil
    @max_points=opts[:max_points] unless opts[:title] == nil
    @add_to_gradebook==opts[:add_to_gradebook]
    # TODO: Add all the rest of the elements here

    unless opts[:status]=="Editing"
      on AssignmentsList do |list|
        @status=list.status_of @title
      end
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

    # TODO: Add more stuff here as needed...

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

  def submit
    # TODO: Create this method
  end

  def grade
    # TODO: Create this method
  end

end