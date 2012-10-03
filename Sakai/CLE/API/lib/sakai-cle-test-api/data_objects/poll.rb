class PollObject

  include PageHelper
  include Utilities
  include Workflows
  
  attr_accessor :question, :instructions, :options, :opening_date, :closing_date,
                :access, :visibility, :site
  
  def initialize(browser, opts={})
    @browser = browser
    
    defaults = {
      :question=>random_alphanums,
      :options=>[random_alphanums, random_alphanums]
    }
    options = defaults.merge(opts)
    
    @question=options[:question]
    @options=options[:options]
    @opening_date=options[:opening_date]
    @closing_date=options[:closing_date]
    @site=options[:site]
    @instructions=options[:instructions]
    @access=options[:access]
    @visibility=options[:visibility]
    raise "You need to specify a site for your blog entry" if @site==nil
  end
    
  def create
    open_my_site_by_name @site unless @browser.title=~/#{@site}/
    polls unless @browser.title=~/Polls$/
    on Polls do |polls|
      polls.add
    end
    on AddEditPoll do |add|
      add.question.set @question
      add.enter_source_text add.editor, @instructions
      # TODO: Need to add the filling out of more fields here
      add.save_and_add_options
    end
    on AddAnOption do |page|
      if @options.length > 1
        @options[0..-2].each do |option|
          page.enter_source_text page.editor, option
          page.save_and_add_options
        end
        page.enter_source_text(page.editor, @options[-1])
        page.save
      else
        page.enter_source_text(page.editor, @options[0])
        page.save
      end
    end
    on AddEditPoll do |poll|
      poll.save
    end
  end
    
  def edit opts={}
    #TODO: Add stuff here
  end
    
  def view
    #TODO: Add stuff here
  end
    
  def delete
    #TODO: Add stuff here
  end
  
end
    
      