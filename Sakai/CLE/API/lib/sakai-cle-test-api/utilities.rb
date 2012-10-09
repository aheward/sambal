# coding: UTF-8

module Utilities

  # Strips the file name away from the path information.
  #
  # This way it's not necessary to define variables for BOTH the
  # file name and the file path + file name. Just define the
  # path + name and then use this method to extract only the filename
  # portion.
  #
  # NOTE: This may be deprecated in the future, so think hard before
  # using it.
  def get_filename(path_plus_name_string)
    path_plus_name_string =~ /(?<=\/).+/
    return $~.to_s
  end

  # Shorthand method for making a data object for testing.
  def make data_object_class, opts={}
    data_object_class.new @browser, opts
  end

  # Transform for use with data object instance variables
  # that refer to checkboxes or radio buttons.
  def checkbox_setting(checkbox)
    checkbox.set? ? :set : :clear
  end
  alias radio_setting checkbox_setting

end