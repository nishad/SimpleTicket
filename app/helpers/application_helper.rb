# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def current_engineer
    Engineer.find(session[:user])
  end
  
  def current_user
    Employee.find(session[:user])
  end
  
  def activity_indicator(id, padding="0 5px", style="")
    image_tag 'activity_indicator.gif', :size => "16x16", :id => id, :style => "display:none; padding:#{padding}; #{style}"
  end
  
  # This is an RJS helper. Flash messages have been 'deactivated'. To 'reactivate' them you must :
  # go into /public/stylesheets/admin.css and delete {display:none;} on #notices_container
  def flash_notice(flash_message)
    page.replace_html 'notices_container', :partial => 'admin/shared/notice', :object => flash_message
    page.delay(5) do
        page.visual_effect :fade, 'green_notice'
    end
  end
  
  # This is an RJS helper. Flash messages have been 'deactivated'. To 'reactivate' them you must :
  # go into /public/stylesheets/admin.css and delete {display:none;} on #notices_container
  def flash_warning(flash_message)
    page.replace_html 'notices_container', :partial => 'admin/shared/warning', :object => flash_message
    page.delay(5) do
        page.visual_effect :fade, 'red_notice'
    end
  end
  
  # flash div generator
  # http://www.bigbold.com/snippets/posts/show/1349
  def flash_div *keys
    keys.collect { |key| content_tag(:div, flash[key],
                                     :class => "flash-#{key}") if flash[key] }.join
  end
  
  def pagination_for(people_count, limit=10, page=1)
    if people_count >= limit
      if (people_count/limit).type == Fixnum
        number_of_pages = (people_count/limit).to_i+1
      else
        number_of_pages = (people_count/limit).to_i
      end
      print = []
      (1..number_of_pages).each do |no|
        no == page ? print << no : print << link_to( no, { :action => controller.action_name, :params => { :page => no, :limit => limit } } )
      end if number_of_pages > 1
      return print.join(' ')
    else 
      return ''
    end
  end
end
