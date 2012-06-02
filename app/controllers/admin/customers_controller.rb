class Admin::CustomersController < Admin::BaseController
  model 'customer'

  def index
    @customer_pages, @customers = paginate :customers,  :order => 'name'
  end

  def new
    @customer = Customer.new
    @states = State.find(:all)
    render_without_layout
  end

  def create
    @customer = Customer.new(params[:customer])
    if @customer.save
      flash[:notice] = "Customer successfully created"
      render :update do |page|
        # We close the JS lightbox with custom JS
        page << "lightbox.prototype.deactivate();"
        # We insert the newly created ticket at the top of the tickets table
        page.insert_html :after, 'customers_table_header', :partial => 'customer', 
                                                         :object => @customer
        # We highlight it
        page.visual_effect :highlight, "cust_#{@customer.id}"
        #once page loaded lightbox object need to create manually if added by ajax like this..
        page << "new lightbox($('row_lbox_#{@customer.id}'))"
      end
    else
      # This happens if the customer has problems getting saved (validations)
      # One line of RJS so it's inline
      render :update do |page|
        page.alert @customer.errors.each_full { |msg| p " #{msg}" }  
      end
    end
  end

  def edit
    @customer = Customer.find(params[:id])
    @states = State.find(:all)
    render_without_layout
  end
  
  def update
    @customer = Customer.find(params[:id])
    @customer.attributes = params[:customer]
    if @customer.save
      flash[:notice] = "Customer info successfully updated"
      flash.discard(:notice)
      render :update do |page|
        # We close the JS lightbox with custom JS
        page << "lightbox.prototype.deactivate();"
        # We remove the actual customer line with it's details
        page.remove "cust_#{@customer.id}", "cust_#{@customer.id}_details"
        # We insert the newly created ticket at the top of the tickets table
        page.insert_html :after, 'customers_table_header', :partial => 'customer', :object => @customer
        # We highlight it
        page.visual_effect :highlight, "cust_#{@customer.id}"
        #once page loaded lightbox object need to create manually if added by ajax like this..
        page << "new lightbox($('row_lbox_#{@customer.id}'))"
      end
    else
      # This happens if the customer has problems getting saved (validations)
      # One line of RJS so it's inline
      render :update do |page|
        page.alert @customer.errors.each_full { |msg| p " #{msg}" } 
      end
    end
  end
end
