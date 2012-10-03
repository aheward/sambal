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
  end
    
  def create
    
  end
    
  def edit opts={}
    
  end
    
  def view
    
  end
    
  def delete
    
  end
  
end
    
      