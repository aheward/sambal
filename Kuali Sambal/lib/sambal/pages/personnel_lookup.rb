class PersonnelLookup < BasePage

  wrapper_elements
  green_search_buttons
  expected_element :principal_name

  def frm
    self.frame(class: "fancybox-iframe")
  end

  element(:principal_name) { |b| b.frm.div(data_label: "Principal Name").text_field }
  element(:id_field) { |b| b.frm.div(data_label: "ID").text_field }
  element(:last_name) { |b| b.frm.div(data_label: "Last Name").text_field }
  element(:results_table) { |b| b.frm.div(id: "uLookupResults").table(index: 0) }

  element(:paginate_links_span) { |b| b.frm.div(class: "dataTables_paginate paging_full_numbers").span() }

  # Clicks the 'return value' link for the named row
  def return_value(principal_name)
    target_row(principal_name).wait_until_present
    target_row(principal_name).link(text: "return value").wait_until_present
    target_row(principal_name).link(text: "return value").click
    loading.wait_while_present
  end

  def target_row(principal_name)
    results_table.row(text: /#{principal_name}/)
  end

  def change_results_page(page_number)
    results_table.wait_until_present
   paginate_links_span.link(text: "#{page_number}").click
  end
end