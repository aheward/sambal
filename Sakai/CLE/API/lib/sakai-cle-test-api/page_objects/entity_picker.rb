class EntityPicker < BasePage

  def view_assignment_details(title)
    unless self.div(:class=>"title", :text=>title).present?
      self.link(:text=>"Assignments").wait_until_present(5)
      self.link(:text=>"Assignments").click
      self.link(:text=>title).wait_until_present(15)
      self.link(:text=>title).click
    end
    self.div(:class=>"title", :text=>title).wait_until_present(5)
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

  def view_forum_details(title)
    unless self.span(:class=>"entity-item-label icon-sakai-entity-forum", :text=>title).present?
      self.link(:class=>/entity-item-label icon-sakai-entity-forum/).wait_until_present(10)
      self.link(:class=>/entity-item-label icon-sakai-entity-forum/).click
      self.link(:text=>title).wait_until_present(10)
      self.link(:text=>title).click
    end
    self.div(:class=>"title", :text=>title).wait_until_present
  end

  def view_topic_details(forum, topic)
    unless self.span(:class=>"entity-item-label icon-sakai-entity-forum", :text=>title).present?
      self.link(:class=>/entity-item-label icon-sakai-entity-forum/).wait_until_present(10)
      self.link(:class=>/entity-item-label icon-sakai-entity-forum/).click
      self.link(:text=>forum).wait_until_present(10)
      self.link(:text=>forum).click
      self.link(:text=>topic).wait_until_present(10)
      self.link(:text=>topic).click
    end
    self.div(:class=>"title", :text=>topic).wait_until_present(10)
  end

  value(:url) { |b| b.td(text: "url").parent.td(class: "attrValue").text }
  value(:portal_url) { |b| b.td(text: "portalURL").parent.td(class: "attrValue").text }
  value(:direct_link) { |b| b.link(text: "Select this item").href }
  value(:retract_time) { |b| b.td(text: "Retract Time").parent.td(class: "attrValue").text }
  value(:time_due) { |b| b.td(text: "Time Due").parent.td(class: "attrValue").text }
  value(:time_modified) { |b| b.td(text: "Time Modified").parent.td(class: "attrValue").text }
  value(:description) { |b| b.td(text: "Description").parent.td(class: "attrValue").text }
  value(:time_created) { |b| b.td(text: "Time Created").parent.td(class: "attrValue").text }
  value(:date_created) { |b| b.td(text: "Date Created").parent.td(class: "attrValue").text }
  value(:author) { |b| b.td(text: "Author").parent.td(class: "attrValue").text }
  value(:moderated) { |b| b.td(text: "Moderated").parent.td(class: "attrValue").text }
  value(:modified_by) { |b| b.td(text: "Modified By").parent.td(class: "attrValue").text }
  value(:date_modified) { |b| b.td(text: "Date Modified").parent.td(class: "attrValue").text }

end