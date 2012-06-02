class Admin::TagsController < Admin::BaseController

  def create
    # We find the ticket to add the tags to and the existing tags
    ticket = Ticket.find(params[:id], :include => [:tags])
    existing_tags = ticket.tags
    # we initalise a table that will contain new tags
    new_tags = []
    # we parse the tag list we have received (groups of words between "" are considered as groups of words...)
    Tag.parse(params[:tags][:tags]).collect do |name|
      # we add these new tags to the ticket unless they already exist
      new_tags << Tag.find_or_create_by_name(name).on(ticket) unless existing_tags.include?(name)
    end
    flash[:notice] = "Successfully added tag(s)!"
    flash.discard(:notice)
    render :update do |page|
      # First we try to hide the 'no tag!' sentence if it's still there
      page.hide "no_tags_#{ticket.id}" if existing_tags == []
      # We add the tag(s)
      page.insert_html(:bottom, "ticket_#{ticket.id}_tags", {:partial => 'list', :collection => new_tags})
      # We highlight
      new_tags.each do |tag|
        page.visual_effect :highlight, "ticket_tagging_#{tag.id}"
      end 
      # We show a flash notice
      # This is a helper method in ApplicationHelpers
      page.flash_notice(flash[:notice])
    end
  end
  
  def delete
    Tagging.destroy(params[:id])
    render :nothing => true
  end
end