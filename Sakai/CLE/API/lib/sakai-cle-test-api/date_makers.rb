# Some date and time helper functions....
module DateMakers

  MONTHS = %w{JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC}
  # Returns the value of the last hour as an Integer object, which
  # eliminates the zero-padding for single-digit hours. 12-hour clock.
  def an_hour_ago
    date_factory(Time.now - 3600)
  end
  alias last_hour an_hour_ago

  # Returns the value of the current hour as an Integer object, which
  # eliminates the zero-padding for single-digit hours. 12-hour clock.
  def right_now
    date_factory(Time.now)
  end

  # Returns the value of the next hour as an Integer object, which
  # eliminates the zero-padding for single-digit hours. 12-hour clock.
  def in_an_hour
    date_factory(Time.now + 3600)
  end
  alias next_hour in_an_hour

  # Returns a 4-digit Integer object, equal to last year.
  def last_year
    date_factory(Time.now - (3600*24*365))
  end
  alias a_year_ago last_year

  # Returns an all-caps 3-char string equal to the prior month
  def last_month
    index = MONTHS.index(current_month)
    return MONTHS[index-1]
  end

  def hours_ago(num)
    date_factory(Time.now - num*3600)
  end

  def hours_from_now(num)
    date_factory(Time.now + num*3600)
  end

  def minutes_ago(num)
    date_factory(Time.now - num*60)
  end

  def minutes_from_now(num)
    date_factory(Time.now + num*60)
  end

  # Returns an all-caps 3-char string equal to the current month
  def current_month
    Time.now.strftime("%^b")
  end

  # Returns an all-caps 3-char string equal to next month
  def next_month
    index = MONTHS.index(current_month)
    if index < 11
      return MONTHS[index+1]
    else
      return MONTHS[0]
    end
  end

  # Returns a 4-digit Integer object equal to next year.
  def in_a_year
    date_factory(Time.now + (3600*24*365))
  end

  # Returns an Integer object equal to
  # yesterday's day of the month. The string is converted to
  # an integer so as to remove the zero-padding from single-digit day values.
  def yesterday
    date_factory(Time.now - (3600*24))
  end

  # Returns an Integer object equal to
  # tomorrow's day of the month. The string is converted to
  # an integer so as to remove the zero-padding from single-digit day values.
  def tomorrow
    date_factory(Time.now + (3600*24))
  end

  def in_a_week
    date_factory(Time.now + (3600*24*7))
  end

  def a_week_ago
    date_factory(Time.now - (3600*24*7))
  end

  # Formats a date string Sakai-style.
  # Useful for verifying creation dates and such.
  #
  # Supplied variable must be of of the Time class.
  def make_date(time_object)
    month = time_object.strftime("%b ")
    day = time_object.strftime("%d").to_i
    year = time_object.strftime(", %Y ")
    mins = time_object.strftime(":%M %P")
    hour = time_object.strftime("%l").to_i
    return month + day.to_s + year + hour.to_s + mins
  end

  def date_factory(time_object)
    {
        :sakai=>make_date(time_object),
        :MON => time_object.strftime("%^b"), # => "DEC"
        :Mon => time_object.strftime("%b"), # => "Jan"
        :Month => time_object.strftime("%B"), # => "February"
        :month_int => time_object.month, # => 3
        :day_of_month => time_object.day, # => 17 Note this is not zero-padded
        :weekday => time_object.strftime("%A"), # => "Monday"
        :wkdy => time_object.strftime("%a"), # => "Tue"
        :year => time_object.year, # => 2013
        :hour => time_object.strftime("%I").to_i, # => "07" Zero-padded, 12-hour clock
        :minute => (time_object).strftime("%M"), # => "02" Zero-padded
        :minute_rounded => (Time.at(time_object.to_i/(5*60)*(5*60))).strftime("%M"), # => "05" Zero-padded, rounded to 5-minute increments
        :meridian => time_object.strftime("%P"), # => "pm"
        :MERIDIAN => time_object.strftime("%p") # => "AM"
    }
  end

end