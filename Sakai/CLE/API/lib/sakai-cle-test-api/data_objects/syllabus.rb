class SyllabusObject

  include PageHelper
  include Utilities
  include Workflows

  attr_accessor :title, :content, :site

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        :title=>random_alphanums,
        :content=>random_multiline(50, 5, :alpha)
    }
    options = defaults.merge(opts)
    @title=options[:title]
    @content=options[:content]
    @site=options[:site]
    raise "You must specify a Site for the announcement" if @site==nil
  end

  alias :name :title

  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    syllabus unless @browser.title=~/Syllabus$/
    on Syllabus do |add|
      add.create_edit
      add.add
    end
    on AddEditSyllabusItem do |create|
      create.title.set @title
      create.enter_source_text create.editor, @content
      create.post
    end
  end

  def edit opts={}
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    syllabus unless @browser.title=~/Syllabus$/
    on Syllabus do |syllabus|
      reset
      syllabus.create_edit
    end
    on SyllabusEdit do |edit|
      edit.open_item @title
    end
    on AddEditSyllabusItem do |item|
      item.title.set opts[:title] unless opts[:title]==nil
      item.enter_source_text(item.editor, opts[:content]) unless opts[:content]==nil
    end
    @title = opts[:title] unless opts[:title]==nil
    @content = opts[:content] unless opts[:content]==nil
  end

  def get_properties
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    syllabus unless @browser.title=~/Syllabus$/
    on Syllabus do |syllabus|
      reset
      syllabus.create_edit
    end
    on SyllabusEdit do |edit|
      edit.open_item @title
    end
    on AddEditSyllabusItem do |item|
      @content = item.get_source_text(item.editor)
      # Add more here as necessary...
    end
  end

end