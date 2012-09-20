class AnnouncementObject

  include Utilities
  include PageHelper
  include Workflows

  attr_accessor :title, :body, :site, :link

  def initialize(browser, opts={})
    @browser = browser

    defaults = {
        :title=>random_alphanums,
        :body=>random_multiline(500, 10, :alpha)
    }
    options = defaults.merge(opts)
    @title=options[:title]
    @body=options[:body]
    @site=options[:site]
    raise "You must specify a Site for the announcement" if @site==nil
  end

  alias :name :title

  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    announcements unless @browser.title=~/Announcements$/
    on_page Announcements do |page|
      page.add
    end
    on_page AddEditAnnouncements do |page|
      page.title.set @title
      page.body=@body
      page.add_announcement
    end
    on_page Announcements do |page|
      @link = page.href(@title)
    end
  end

  def edit opts={}
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    announcements unless @browser.title=~/Announcements$/
    on_page Announcements do |list|
      list.edit @title
    end
    on AddEditAnnouncements do |edit|
      edit.title.set opts[:title] unless opts[:title]==nil
      unless opts[:body]==nil
        edit.source(:editor)

      end
    end
  end
end