class CalendarBase < BasePage

  frame_element
  basic_page_elements

  class << self
    def menu_elements
      # AddEditEvent
      action(:add_event) { |b| b.frm.link(:text=>"Add").click }

      # AddEditFields
      action(:fields) { |b| b.frm.link(:text=>"Fields").click }

      # ImportStepOne
      action(:import) { |b| b.frm.link(:text=>"Import").click }

      #TODO: Finish adding menu buttons here
    end
  end

end

# Top page of the Calendar
# For now it includes all views, though that probably
# means it will have to be re-instantiated every time
# a new view is selected.
class Calendar < CalendarBase

  menu_elements

  # Selects the specified item in the View select list.
  element(:view) { |b| b.frm.select(:id=>"view") }

  # Selects the specified item in the Show select list.
  element(:show) { |b| b.frm.select(:id=>"timeFilterOption") }
  alias :show_events :show

  # Clicks the link to the specified event, then
  # instantiates the EventDetail class.
  def open_event(title)
    truncated = title[0..5]
    frm.link(:text=>/#{Regexp.escape(truncated)}/).click
  end

  # Returns the href value of the target link
  # use for validation when you are testing whether the link
  # will appear again on another screen, since often times
  # validation by title text alone will not work.
  def event_href(title)
    truncated = title[0..5]
    frm.link(:text=>/#{Regexp.escape(truncated)}/).href
  end

  # Selects the specified value in the start month select list.
  element(:start_month) { |b| b.frm.select(:id=>"customStartMonth") }

  # Selects the specified value in the start day select list.
  element(:start_day) { |b| b.frm.select(:id=>"customStartDay") }

  # Selects the specified value in the start year select list.
  element(:start_year) { |b| b.frm.select(:id=>"customStartYear") }

  # Selects the specified value in the end month select list.
  element(:end_month) { |b| b.frm.select(:id=>"customEndMonth") }

  # Selects the specified value in the End Day select list.
  element(:end_day) { |b| b.frm.select(:id=>"customEndDay") }

  # Selects the specified value in the End Year select list.
  element(:end_year) { |b| b.frm.select(:id=>"customEndYear") }

  # Clicks the Filter Events button, then re-instantiates
  # the Calendar class to avoid the possibility of an
  # ObsoleteElement error.
  action(:filter_events) { |b| b.frm.button(:name=>"eventSubmit_doCustomdate").click }

  # Clicks the Go to Today button, then reinstantiates
  # the Calendar class.
  action(:go_to_today) { |b| b.frm.button(:value=>"Go to Today").click }

  # Returns an array for the listed events.
  # This array contains more than simply strings of the event titles, because
  # often the titles are truncated to fit on the screen. In addition, getting the "title"
  # tag of the link is often problematic because titles can contain double-quotes, which
  # will mess up the HTML of the anchor tag (there is probably an XSS vulnerability to
  # exploit, there. This should be extensively tested.).
  #
  # Because of these issues, the array contains the title tag, the anchor text, and
  # the entire href string for every event listed on the page. Having all three items
  # available should ensure that verification steps don't give false results--especially
  # when you are doing a negative test (checking that an event is NOT present).
  def events_list
    list = {}
    if frm.table(:class=>"calendar").exist?
      events_table = frm.table(:class=>"calendar")
    else
      events_table = frm.table(:class=>"listHier lines nolines")
    end
    events_table.links.each do |link|
      list.store(link.title, {:text=>link.text,
                              :href=>link.href,
                              :html=>link.html[/(?<="location=").+doDescription/] }
                )
    end
    list
  end
  alias event_list events_list
  alias events event_list

  # Clicks the "Previous X" button, where X might be Day, Week, or Month,
  # then reinstantiates the Calendar class to ensure against any obsolete element
  # errors.
  action(:previous) { |b| b.frm.button(:name=>"eventSubmit_doPrev").click }

  # Clicks the "Next X" button, where X might be Day, Week, or Month,
  # then reinstantiates the Calendar class to ensure against any obsolete element
  # errors.
  action(:next) { |b| b.frm.button(:name=>"eventSubmit_doNext").click }

  # Clicks the "Today" button and reinstantiates the class.
  action(:today) { |b| b.frm.button(:value=>"Today").click }

  action(:earlier) { |b| b.frm.link(:text=>"Earlier").click }

  action(:later) { |b| b.frm.link(:text=>"Later").click }

  # Clicks the "Set as Default View" button
  action(:set_as_default_view) { |b| b.frm.link(:text=>"Set as Default View").click }

end

# The page that appears when you click on an event in the Calendar
class EventDetail < CalendarBase

  menu_elements
  # Clicks the Go to Today button, then instantiates
  # the Calendar class.
  action(:go_to_today) { |b| b.frm.button(:value=>"Go to Today").click }

  action(:back_to_calendar) { |b| b.frm.button(:value=>"Back to Calendar").click }

  action(:last_event) { |b| b.frm().button(:value=>"< Last Event").click }

  action(:next_event) { |b| b.frm().button(:value=>"Next Event >").click }

  value(:event_title) { |b| b.frm.div(:class=>"portletBody").h3.text }

  action(:edit) { |b| b.frm.button(:value=>"Edit").click }

  action(:remove_event) { |b| b.frm.button(:value=>"Remove event").click }

  # Returns a hash object containing the contents of the event details
  # table on the page, with each of the header column items as a Key
  # and the associated data column as the corresponding Value.
  def details
    details = {}
    frm.table(:class=>"itemSummary").rows.each do |row|
      details.store(row.th.text, row.td.text)
    end
    details
  end

  value(:message_html) { |b| b.frm.th(text: "Description").parent.td.html }

end

#
class AddEditEvent < CalendarBase

  include FCKEditor

  menu_elements

  expected_element :editor

  # Calendar class
  action(:save_event) { |b| b.frm.button(:value=>"Save Event").click }

  def message=(text)
    editor.td(:id, "xEditingArea").frame(:index=>0).send_keys(text)
  end

  # The FCKEditor object. Use this method to set up a "wait_until_present"
  # step, since sometimes it takes a long time for this object to load.
  element(:editor) { |b| b.frm.frame(:id, "description___Frame") }

  action(:frequency) { |b| b.frm.button(:name=>"eventSubmit_doEditfrequency").click }

  action(:add_attachments) { |b| b.frm.button(:value=>"Add Attachments").click }

  action(:add_remove_attachments) { |b| b.frm.button(:value=>"Add/remove attachments").click }

  # Returns true if the page has a link with the
  # specified file name. Use for test case asserts.
  def attachment?(file_name)
    frm.link(:text=>file_name).exist?
  end

  # Use this method to enter text into custom fields
  # on the page. The "field" variable is the name of the
  # field, while the "text" is the string you want to put into
  # it.
  def custom_field_text(field, text)
    frm.text_field(:name=>field).set(text)
  end

  element(:title) { |b| b.frm.text_field(:id=>"activitytitle") }
  element(:month) { |b| b.frm.select(:id=>"month") }
  element(:day) { |b| b.frm.select(:id=>"day") }
  element(:year) { |b| b.frm.select(:id=>"yearSelect") }
  element(:start_hour) { |b| b.frm.select(:id=>"startHour") }
  element(:start_minute) { |b| b.frm.select(:id=>"startMinute") }
  element(:start_meridian) { |b| b.frm.select(:id=>"startAmpm") }
  element(:hours) { |b| b.frm.select(:id=>"duHour") }
  element(:minutes) { |b| b.frm.select(:id=>"duMinute") }
  element(:end_hour) { |b| b.frm.select(:id=>"endHour") }
  element(:end_minute) { |b| b.frm.select(:id=>"endMinute") }
  element(:end_meridian) { |b| b.frm.select(:id=>"endAmpm") }
  element(:display_to_site) { |b| b.frm.radio(:id=>"site") }
  element(:event_type) { |b| b.frm.select(:id=>"eventType") }
  element(:location) { |b| b.frm.text_field(:name=>"location") }

end

# The page that appears when the Frequency button is clicked on the Add/Edit
# Event page.
class EventFrequency < CalendarBase

  action(:save_frequency) { |b| b.frm.button(:value=>"Save Frequency").click }

  action(:cancel) { |b| b.frm.button(:value=>"Cancel").click }

  element(:event_frequency) { |b| b.frm.select(:id=>"frequencySelect") }
  element(:interval) { |b| b.frm.select(:id=>"interval") }
  element(:ends_after) { |b| b.frm.select(:name=>"count") }
  element(:ends_month) { |b| b.frm.select(:id=>"endMonth") }
  element(:ends_day) { |b| b.frm.select(:id=>"endDay") }
  element(:ends_year) { |b| b.frm.select(:id=>"endYear") }
  element(:after) { |b| b.frm.radio(:id=>"count") }
  element(:on) { |b| b.frm.radio(:id=>"till") }
  element(:never) { |b| b.frm.radio(:id=>"never") }

end

class AddEditFields < CalendarBase

  # Clicks the Save Field Changes buton and instantiates
  # The Calendar or EventDetail class--unless the Alert Message box appears,
  # in which case it re-instantiates the class.
  action(:save_field_changes) { |b| b.frm.button(:value=>"Save Field Changes").click }

  action(:create_field) { |b| b.frm.button(:value=>"Create Field").click }

  # Checks the checkbox for the specified field
  def check_remove(field_name)
    frm.table(:class=>/listHier lines/).row(:text=>/#{Regexp.escape(field_name)}/).checkbox.set
  end

  element(:field_name) { |b| b.frm.text_field(:id=>"textfield") }

end

class ImportStepOne < BasePage

  frame_element

  action(:continue) { |b| b.frm.button(:value=>"Continue").click }
  element(:microsoft_outlook) { |b| b.frm.radio(:id=>"importType_Outlook") }
  element(:meeting_maker) { |b| b.frm.radio(:id=>"importType_MeetingMaker") }
  element(:generic_calendar_import) { |b| b.frm.radio(:id=>"importType_Generic") }

end

class ImportStepTwo < BasePage

  frame_element

  # Goes to ImportStepThree
  action(:continue) { |b| b.frm.button(:value=>"Continue").click }

  # Enters the specified filename in the file field.
  #
  # Note that the file path is an optional second parameter, if you do not want to
  # include the full path in the filename.
  def import_file(filename, filepath="")
    frm.file_field(:name=>"importFile").set(filepath + filename)
  end

end

class ImportStepThree < BasePage

  frame_element

  expected_element :import_events_for_site

  # Goes to Calendar
  action(:import_events) { |b| b.frm.button(:value=>"Import Events").click }

  # Returns an array containing the list of Activity names on the page.
  def events
    list = []
    frm.table(:class=>/listHier lines/).rows.each do |row|
      if row.label(:for=>/eventSelected/).exist?
        list << row.label.text
      end
    end
    names = []
    list.uniq!
    list.each do | item |
      name = item[/(?<=\s).+(?=\s\s\()/]
      names << name
    end
    names
  end

  # Returns the date of the specified event
  def event_date(event_name)
    frm.table(:class=>/listHier lines/).row(:text=>/#{Regexp.escape(event_name)}/)[0].text
  end

  # Unchecks the checkbox for the specified event
  def uncheck_event(event_name)
    frm.table(:class=>/listHier lines/).row(:text=>/#{Regexp.escape(event_name)}/)
  end

  element(:import_events_for_site) { |b| b.frm.radio(:id=>"site") }
  element(:import_events_for_selected_groups) { |b| b.frm.radio(:id=>"groups") }

end