class TicketUpdate < ActiveRecord::Base
  belongs_to :ticket, :order => "created_at"
  belongs_to :action
  belongs_to :user
  # belongs_to :engineer, :class_name => "User"
#  belongs_to :customer
  validates_presence_of :user, :on => :create, :message => "can't be blank"
  validates_presence_of :comment, :on => :create, :message => "can't be blank"
  validates_presence_of :time_spent, :on => :create, :message => "can't be blank"
  

  file_column :file, {:permissions => 0777}
end

#class EngineerTicketUpdate < TicketUpdate
#  belongs_to  :engineer, :foreign_key => "user_id"
#  validates_presence_of :time_spent
#end

#class EmployeeTicketUpdate < TicketUpdate
#  belongs_to  :employee, :foreign_key => "user_id"
#end
