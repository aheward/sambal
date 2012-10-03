class ChatRoomObject

  include PageHelper
  include Utilities
  include Workflows
  
  attr_accessor :title, :description, :chat_display, :allow_change, :site
  
  def initialize(browser, opts={})
    @browser = browser
    
    defaults = {
      :title=>random_alphanums,
      :description=>random_alphanums,
      :chat_display=>:show_all_messages,
      :allow_change=>:set
    }
    options = defaults.merge(opts)
    
    @title=options[:title]
    @description=options[:description]
    @chat_display=options[:chat_display]
    @allow_change=options[:allow_change]
    @site=options[:site]
    raise "You need to specify a site for your chat room" if @site==nil
  end
    
  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    chat_room unless @browser.title=~/Chat Room$/
    on ChatRoom do |chat|
      chat.options
    end
    on ManageRooms do |manage|
      manage.add_room
    end
    #TODO: finish this method
  end
    
  def edit opts={}
    
  end
    
  def view
    
  end
    
  def delete
    
  end
  
end
    
      