
gem "test-unit"
require "test/unit"
require 'sakai-cle-test-api'
require 'yaml'

class TestImportSite < Test::Unit::TestCase
  
  include Utilities

  def setup
    
    # Get the test configuration data
    @config = YAML.load_file("config.yml")
    @directory = YAML.load_file("directory.yml")
    @sakai = SakaiCLE.new(@config['browser'], @config['url'])
    @browser = @sakai.browser
    # This test case uses the logins of several users
    @instructor = "admin"
    @ipassword = "admin"
    @file_path = @config['data_directory']
    @source_site_string = "Links to various items in this site:"

  end
=begin
  def teardown
    # Close the browser window
    @browser.close
  end
=end
  def test_import_site_materials

    # Log in to Sakai
    @sakai.page.login(@instructor, @ipassword)

    @site1 = make SiteObject, :description=>"Original Site"
    @site1.create

    @source_site_string << "<br />\n<br />\nSite ID: #{@site1.id}<br />\n<br />\n"

    @assignment = make AssignmentObject, :site=>@site1.name, :instructions=>@source_site_string
    @assignment.create
    @assignment.get_info

    @source_site_string << "Assignment...<br />\nID:(n) #{@assignment.id}<br />\n"
    @source_site_string << "Link (made 'by hand'): <a href=\"#{@assignment.link}\">#{@assignment.title}</a><br />\n"
    @source_site_string << "URL from Entity picker:(x) <a href=\"#{@assignment.url}\">#{@assignment.title}</a><br />\n"
    @source_site_string << "<em>Direct</em> URL from Entity picker:(y) <a href=\"#{@assignment.direct_url}\">#{@assignment.title}</a><br />\n<br />\n#{@assignment.direct_url}<br />\n<br />\n"
    @source_site_string << "<em>Portal</em> URL from Entity picker:(z) <a href=\"#{@assignment.portal_url}\">#{@assignment.title}</a><br />\n<br />\n#{@assignment.portal_url}<br />\n<br />\n"

    @announcement = make AnnouncementObject, :site=>@site1.name, :body=>@assignment.link
    @announcement.create

    @source_site_string << "<br />\nAnnouncement link: <a href=\"#{@announcement.link}\">#{@announcement.title}</a><br />"

    @file = make FileObject, :site=>@site1.name, :name=>"flower02.jpg", :source_path=>@file_path+"images/"
    @file.create

    @source_site_string << "<br />Uploaded file: <a href=\"#{@file.href}\">#{@file.name}</a><br />"

    @htmlpage = make HTMLPageObject, :site=>@site1.name, :folder=>"#{@site1.name} Resources", :html=>@source_site_string
    @htmlpage.create

    @source_site_string << "<br />HTML Page: <a href=\"#{@htmlpage.url}\">#{@htmlpage.name}</a><br />"

    @folder = make FolderObject, :site=>@site1.name, :parent_folder=>"#{@site1.name} Resources"
    @folder.create

    @nestedhtmlpage = make HTMLPageObject, :site=>@site1.name, :folder=>@folder.name, :html=>@source_site_string
    @nestedhtmlpage.create

    @source_site_string << "<br />Nested HTML Page: <a href=\"#{@nestedhtmlpage.url}\">#{@nestedhtmlpage.name}</a><br />"

    @web_content1 = make WebContentObject, :title=>@htmlpage.name, :source=>@htmlpage.url, :site=>@htmlpage.site
    @web_content1.create

    @web_content2 = make WebContentObject, :title=>@nestedhtmlpage.name, :source=>@nestedhtmlpage.url, :site=>@nestedhtmlpage.site
    @web_content2.create

    @module = make ModuleObject, :site=>@site1.name
    @module.create

    @source_site_string << "<br />Module: <a href=\"#{@module.href}\">#{@module.name}</a><br />"

    @section1 = make ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Compose content with editor",
                     :editor_content=>@source_site_string
    @section1.create

    @source_site_string << "<br />Section 1: <a href=\"#{@section1.href}\">#{@section1.name}</a><br />"

    @section2 = make ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Upload or link to a file",
                     :file_name=>"flower01.jpg", :file_path=>@file_path+"images/"
    @section2.create

    @source_site_string << "<br />Section 2: <a href=\"#{@section2.href}\">#{@section2.name}</a><br />"

    @section3 = make ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Link to new or existing URL resource on server",
                    :url=>@htmlpage.url, :url_title=>@htmlpage.name
    @section3.create

    @section4 = make ContentSectionObject, :site=>@site1.name, :module=>@module.title, :content_type=>"Upload or link to a file in Resources",
        :file_name=>@nestedhtmlpage.name, :file_folder=>@nestedhtmlpage.folder
    @section4.create

    @wiki = make WikiObject, :site=>@site1.name, :content=>"{image:worksite:/#{@file.name}}\n\n{worksiteinfo}\n\n{sakai-sections}"
    @wiki.create

    @source_site_string << "<br />Wiki: <a href=\"#{@wiki.href}\">#{@wiki.title}</a><br />"

    @syllabus = make SyllabusObject, @content=>@source_site_string, :site=>@site1.name
    @syllabus.create

    @source_site_string << "<br />Syllabus: "

    @assignment.edit :instructions=>@source_site_string

    @announcement.edit :body=>@source_site_string

    @htmlpage.edit_content @source_site_string

    @nestedhtmlpage.edit_content @source_site_string

    @section1.edit :editor_content=>@source_site_string

    @site2 = make SiteObject
    @site2.create_and_reuse_site @site1.name

    @new_assignment = make AssignmentObject, :site=>@site2.name, :status=>"Draft", :title=>@assignment.title
    @new_assignment.get_info

    puts "Web Content Link 1 updated? " + (@browser.link(:text=>@web_content1.title, :href=>/#{@site2.id}/).present? ? "yes" : "no")
    puts "Web Content Link 2 updated? " + (@browser.link(:text=>@web_content2.title, :href=>/#{@site2.id}/).present? ? "yes" : "no")

    def check_this_stuff(thing)
      puts "Site ID Updated? " + (thing[/Site ID: #{@site2.id}/]==nil ? "no" : "yes")
      puts "Assignment ID updated? " + (thing[/ID:\(n\) #{@new_assignment.id}/]==nil ? "no" : "yes")
      puts "Old Assignment ID still there? "  + (thing[/ID:\(n\) #{@assignment.id}/]==nil ? "no" : "yes")
      puts "Assignment Link updated? " + (thing[/hand.\): <a href.+#{@new_assignment.link}.+doView_assignment/]==nil ? "no" : "yes")
      puts "Entity picker Assignment URL updated? " + (thing[/\(x\) <a href.+#{@new_assignment.url}.+doView_submission/]==nil ? "no" : "yes")
      puts "Assignment Direct link updated? " + (thing[/\(y\) <a href..#{@new_assignment.direct_url}/]==nil ? "no" : "yes")
      puts "Assignment Portal Link updated? " + (thing[/\(z\) <a href..#{@new_assignment.portal_url}/]==nil ? "no" : "yes")
      puts "Announcement Link updated? " + (thing[/#{@announcement.id}/]==nil ? "yes" : "no")
      puts "File Link updated? " + (thing[/Uploaded file:.+#{@site2.id}.+#{@file.name}/]==nil ? "no" : "yes")
      puts "HTML Page Link updated? " + (thing[/#{@site2.id}\/#{@htmlpage.name}/]==nil ? "no" : "yes")
      puts "Nested HTML Page Link updated? " + (thing[/#{@site2.id}\/#{@folder.name}\/#{@nestedhtmlpage.name}/]==nil ? "no" : "yes")
      puts "Module Link updated? " + (thing[/Module:.+#{@site2.id}.+#{@module.name}/]==nil ? "no" : "yes")
      puts "Section 1 Link updated? " + (thing[/Section 1:.+#{@site2.id}.+#{@section1.name}/]==nil ? "no" : "yes")
      puts "Section 2 Link updated? " + (thing[/Section 2:.+#{@site2.id}.+#{@section2.name}/]==nil ? "no" : "yes")
      puts "Section 3 Link updated? " + (thing[/Section 3:.+#{@site2.id}.+#{@section3.name}/]==nil ? "no" : "yes")
      puts "Section 4 Link updated? " + (thing[/Section 4:.+#{@site2.id}.+#{@section4.name}/]==nil ? "no" : "yes")
      #puts "Wiki link updated? " + (thing[/#{@site2.id}/]==nil ? "no" : "yes")
      #puts "Syllabus Link updated? " + (thing[/Syllabus: #{@site2.id}/]==nil ? "no" : "yes")
    end

    puts "\nChecking Assignment...\n"
    check_this_stuff(@new_assignment.instructions)

    @new_announcement = make AnnouncementObject, :site=>@site2.name, :title=>@announcement.title
    @new_announcement.view

    puts "\nChecking Announcement...\n"
    check_this_stuff(@new_announcement.message_html)
    
    puts "\nOriginal Assignment ID: #{@assignment.id}\n\n"
    puts "Original Assignment instructions:\n\n"
    puts @assignment.instructions
    puts "\n\n"

    puts "new_assignment ID: " + @new_assignment.id + "\n\n"
    puts "New Assignment instructions:\n\n"
    puts @new_assignment.instructions

  end
  
end
