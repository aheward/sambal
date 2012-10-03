module FCKEditor

  # This has to be defined this way because there several pages
  # that have multiple rich text editors.
  def source(editor)
    editor.div(:title=>/Source/).wait_until_present
    editor.div(:title=>/Source/).click
  end

  def select_all(editor)
    editor.div(:title=>"Select All").wait_until_present
    editor.div(:title=>"Select All").click
  end

  def enter_source_text(editor, text)
    source(editor)
    source_field(editor).wait_until_present
    source_field(editor).set text
  end

  def get_source_text(editor)
    source(editor)
    source_field(editor).wait_until_present
    source_field(editor).value
  end

  def entity_picker(editor)
    editor.div(:title=>"Sakai_Entity_Link").wait_until_present
    editor.div(:title=>"Sakai_Entity_Link").click
    @browser.frame(:index=>2).frame(:id=>"frmMain").button(:value=>"Browse Server").click
    @browser.window(:index=>1).use
  end

  def source_field(editor)
    editor.text_field(:class=>"SourceField")
  end

end