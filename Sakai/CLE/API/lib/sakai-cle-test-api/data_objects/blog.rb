class BlogEntryObject

  include PageHelper
  include Utilities
  include Workflows
  
  attr_accessor :title, :content, :site, :permissions
  
  def initialize(browser, opts={})
    @browser = browser
    
    defaults = {
      :title=>random_alphanums,
      :content=>random_alphanums,
      :permissions=>:publicly_viewable
    }
    options = defaults.merge(opts)
    
    @title=options[:title]
    @content=options[:content]
    @site=options[:site]
    @permissions=options[:permissions]
    raise "You need to specify a site for your blog entry" if @site==nil
  end
    
  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    blogs unless @browser.title=~/Blogs$/
    # TODO: More needed here
  end
    
  def edit opts={}
    
  end
    
  def view
    
  end
    
  def delete
    
  end
  
end
    
      