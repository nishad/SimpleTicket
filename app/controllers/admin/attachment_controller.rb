class Admin::AttachmentController < Admin::BaseController

  def create
    @ticket = Ticket.find(params[:id])
    @ticket.attachments.build(@params[:attachments])
    if @ticket.save
      flash[:notice] = "File successfully saved!"
      render :update do |page|
        page.replace_html 'notices_container', :partial => 'admin/shared/notice', :object => flash[:notice]
        page.delay(5) do
            page.visual_effect :fade, 'green_notice'
        end
      end
    else
      flash[:warning] = "Problem uploading file!"
      render :update do |page|
        page.alert ticket.errors.each_full { |msg| "#{msg} " }
      end
    end
  end

  def destroy
    @attachment = Attachment.find(params[:id], :include => [:ticket])
    @ticket = @attachment.ticket
    if @attachment.destroy
      flash[:notice] = "File successfully deleted!"
      render :update do |page|
        page.replace_html 'notices_container', :partial => 'admin/shared/notice', :object => flash[:notice]
        page.delay(5) do
            page.visual_effect :fade, 'green_notice'
        end
      end
    else
      flash[:warning] = "Problem deleting file, contact manager!"
      render :update do |page|
        page.alert ticket.errors.each_full { |msg| "#{msg} " }
      end
    end
  end
end
