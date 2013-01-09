class CourseOffering

  include Foundry
  include DataFactory
  include DateFactory
  include StringFactory
  include Workflows

  attr_accessor :term,
                :course,
                :suffix,
                :activity_offering_cluster_list,
                :ao_list,
                :final_exam_type,
                :wait_list,
                :honors_flag,
                :affiliated_person,
                :search_by_subj



  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        :term=>"20122",
        :course=>"ENGL103",
        :suffix=>"",
        :activity_offering_cluster_list=>[],
        :ao_list => [],
        :final_exam_type => "NONE",
        :wait_list => "NO",
        :honors_flag => "NO",
        :affiliated_person => nil,
        :search_by_subj => false
    }
    options = defaults.merge(opts)
    set_options(options)
  end

  def manage
    go_to_manage_course_offerings
    on ManageCourseOfferings do |page|
      page.term.set @term

      if @search_by_subj
        page.input_code.set @course[0,4]
      else
        page.input_code.set @course
      end

      page.show

      begin
        page.link(text: @course).wait_until_present(5)
        page.target_row(@course).link(text: "Manage").click
        page.loading.wait_while_present
      rescue Watir::Wait::TimeoutError
        #means was single CO returned, AO list is already displayed
      end
    end

    on ManageCourseOfferings do |page|
      @ao_list = page.codes_list
    end
  end

  def select_final_option (final_option)
    on CourseOfferingEdit do |page|
      case final_option
        when "Standard final Exam"
          page.final_exam_option_standard == "STANDARD"
          @final_exam_type = "STANDARD"
        when "Alternate final assessment"
          page.final_exam_option_alternate
          @final_exam_type = "ALTERNATE"
        when "No final exam or assessment"
          page.final_exam_option_none
          @final_exam_type = "NONE"
      end
    end
  end

  def select_wait_list_on(list_level, list_type)
    on CourseOfferingEdit do |page|
      page.waitlist_on
      @wait_list = "YES"
      case list_level
        when "Course Offering"
          page.waitlist_option_course_offering
        when "Activity Offering"
          page.waitlist_option_activity_offering
      end
      page.waitlist_select.select(list_type)
    end
  end

  def search_by_subjectcode
    go_to_manage_course_offerings
    on ManageCourseOfferings do |page|
      page.term.set @term
      page.input_code.set @course[0,4]
      page.show
    end
  end

  def honors_flag_on
    on CourseOfferingEdit do |page|
      page.honors_flag.set
      @honors_flag = "YES"
    end
  end

  def view_course_details
    on ManageCourseOfferingList do |page|
      page.view_course_offering @course
    end
  end

  def manage_registration_groups(cleanup=true)
    on ManageCourseOfferings do |page|
      page.manage_registration_groups
    end
    #init
    if cleanup
      cleanup_all_ao_clusters
    end

  end

  def delete_ao(ao_code)
    aoCode = ao_code[:ao_code]
    on ManageCourseOfferings do |page|
      page.delete(aoCode)
    end
    on ActivityOfferingConfirmDelete do |page|
      page.delete_activity_offering
    end
  end

  def copy_ao(ao_code)
    aoCode = ao_code[:ao_code]
    on ManageCourseOfferings do |page|
      page.copy(aoCode)
    end
  end

  def delete_ao_list(ao_code_list)
    @aoCode = ao_code_list[:code_list]
    on ManageCourseOfferings do |page|
      page.select_aos(@aoCode)
      page.selected_offering_actions.select("Delete")
      page.go
    end
    on ActivityOfferingConfirmDelete do |page|
      page.delete_activity_offering
    end
  end

  def ao_status(inputOrg)
    retVal = nil
    aoCode = inputOrg[:inputs][0]
    aoState = inputOrg[:inputs][1]
    on ManageCourseOfferings do |page|
      if page.ao_status(aoCode, aoState)
        retVal = aoState
      end
    end
    retVal
  end

  def ao_schedule_data(ao_code)
    retVal = nil
    aoCode = ao_code[:ao_code]
    on ManageCourseOfferings do |page|
       retVal = page.ao_schedule_data(aoCode)
    end

    retVal
  end

  def add_ao_cluster(ao_cluster)
    @activity_offering_cluster_list << ao_cluster
  end

#  def add_aos_to_clusters
#    @activity_offering_cluster_list.each do |cluster|
#      cluster.add_unassigned_aos
#    end
#  end                                                                                                                                                                                            c

  def expected_unassigned_ao_list
    expected_unassigned = @ao_list
    @activity_offering_cluster_list.each do |cluster|
      expected_unassigned = expected_unassigned - cluster.assigned_ao_list
    end
    expected_unassigned.delete_if { |id| id.strip == "" }
  end

  def create_co_copy
    pre_copy_co_list = []
    post_copy_co_list = []

    go_to_manage_course_offerings
    on ManageCourseOfferings do |page|
      page.term.set @term
      page.input_code.set @course[0,4] #subject code
      page.show
    end
    on ManageCourseOfferingList do |page|
      pre_copy_co_list = page.co_list
      page.copy @course
    end
    on CopyCourseOffering do |page|
      page.create_copy
    end
    on ManageCourseOfferingList do |page|
      post_copy_co_list = page.co_list
    end
    @course = (post_copy_co_list - pre_copy_co_list).first
  end

  def cleanup_all_ao_clusters
    existing_cluster_list = []
    on ManageRegistrationGroups do |page|
      page.cluster_div_list.each do |cluster_div|
        puts "cluster_div.span().text(): #{cluster_div.span().text()}"
        existing_cluster_list << cluster_div.span().text()
      end
    end


    existing_cluster_list.each do |cluster|
      on ManageRegistrationGroups do |page|
        while true
          begin
            sleep 1
            wait_until(10) {page.cluster_list_div.exists? }
            break
          rescue Watir::Wait::TimeoutError #in case generation fails
            break
          rescue Selenium::WebDriver::Error::StaleElementReferenceError
            puts "rescued - generate_unconstrained_reg_groups"
          end
        end
        page.remove_cluster(cluster)
        page.confirm_delete_cluster
      end
    end
  end



end
