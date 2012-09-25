class EntityPicker < BasePage

  def view_assignment_details(title)
    unless self.div(:class=>"title", :text=>title).present?
      self.link(:text=>"Assignments").click
      self.link(:text=>title).wait_until_present
      self.link(:text=>title).click
    end
    self.div(:class=>"title", :text=>title).wait_until_present
  end

  def select_assignment(title)
    view_assignment_details(title)
    self.link(:text=>"Select this item").click
    self.window(:index=>0).use
    self.frame(:index=>2).button(:id=>"btnOk").click
  end

  def close_picker
    self.window.close
    self.window(:index=>0).use
    self.frame(:index=>2).button(:id=>"btnCancel").click
  end

  value(:url) { |b| b.td(text: "url").parent.td(class: "attrValue").text }
  value(:portal_url) { |b| b.td(text: "portalURL").parent.td(class: "attrValue").text }
  value(:direct_link) { |b| b.link(text: "Select this item").href }
  value(:retract_time) { |b| b.td(text: "Retract Time").parent.td(class: "attrValue").text }
  value(:time_due) { |b| b.td(text: "Time Due").parent.td(class: "attrValue").text }
  value(:time_modified) { |b| b.td(text: "Time Modified").parent.td(class: "attrValue").text }
  value(:description) { |b| b.td(text: "Description").parent.td(class: "attrValue").text }
  value(:time_created) { |b| b.td(text: "Time Created").parent.td(class: "attrValue").text }

end