class Admin::UsersController < Admin::BaseController
  
  def ajax_find_users_from_customer_selection
    respond_to do |wants|
      wants.html { redirect_to :controller => tickets, :action => 'index' }
      wants.js {
        customer_id = params[:customer].to_s.to_i
        unless customer_id.nil?
          customer = Customer.find(customer_id)
	  @users = Employee.find(:all, :conditions => ['company_id = ?', customer_id], :order => 'first_name, last_name')
          render :update do |page|
                page.replace_html 'user_select', :partial => 'admin/users/ajax_find_users_from_customer_selection', :object => @users
          end
        end
      }
    end
  end
end
