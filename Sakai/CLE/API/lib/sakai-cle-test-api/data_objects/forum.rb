# Note that this class is for icon-sakai-forums. NOT jforums.
class ForumObject

  include PageHelper
  include Utilities
  include Workflows
  
  attr_accessor :site, :title, :short_description, :description, :direct_link
  
  def initialize(browser, opts={})
    @browser = browser
    
    defaults = {
      :title=>random_alphanums
    }
    options = defaults.merge(opts)
    
    @site=options[:site]
    @title=options[:title]
    @short_description=options[:short_description]
    @description=options[:description]
    raise "You need to specify a site for your Forum" if @site==nil
  end
    
  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    forums unless @browser.title=~/Forums$/
    on Forums do |forums|
      forums.new_forum
    end
    on EditForum do |edit|
      edit.title.set @title
      edit.short_description.set @short_description unless @short_description==nil
      edit.enter_source_text(edit.editor, @description) unless @description==nil
      edit.save
    end
  end
    
  def edit opts={}
    
  end
    
  def view
    
  end
    
  def delete
    
  end

  def get_direct_link

  end

end