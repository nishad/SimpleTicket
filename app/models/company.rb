class Company < ActiveRecord::Base
  belongs_to  :state
  has_many    :employees

  validates_presence_of :name, :address1, :city, :zip, :phone, :maildomain, :contracted_users
  validates_numericality_of :zip
  
  def employee_stats
    Company.find_by_sql("SELECT users.id, concat(users.first_name, ' ', users.last_name) as full_name, open_tickets.count_all as count_open, closed_tickets.count_all as count_closed, logged_time.in_hours as logged_hours, per_ticket.avg_time, per_open_ticket.avg_time as avg_open, per_pending_ticket.avg_time as avg_pending, per_contacted_ticket.avg_time as avg_contacted, (all_high_tickets.count_high/all_tickets.count_all*100) as per_of_high
    FROM users LEFT JOIN 
    	(SELECT user_id, count(*) AS count_all FROM tickets INNER JOIN users ON tickets.user_id = users.id WHERE users.company_id = #{id} and status_id != 4 GROUP BY user_id) as open_tickets
    	ON open_tickets.user_id = users.id LEFT JOIN 
    	(SELECT user_id, count(*) AS count_all FROM tickets INNER JOIN users ON tickets.user_id = users.id WHERE users.company_id = #{id} and status_id = 4 GROUP BY user_id) as closed_tickets
    	ON closed_tickets.user_id = users.id LEFT JOIN 
    	(SELECT tickets.user_id, sum(time_spent)/60 AS in_hours FROM tickets INNER JOIN users ON tickets.user_id = users.id INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE users.company_id = #{id} GROUP BY user_id) as logged_time
    	ON logged_time.user_id = users.id LEFT JOIN 
    	(SELECT tickets.user_id, avg(time_spent) AS avg_time FROM tickets INNER JOIN users ON tickets.user_id = users.id INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE users.company_id = #{id} GROUP BY user_id) as per_ticket
    	ON per_ticket.user_id = users.id LEFT JOIN 
    	(SELECT tickets.user_id, avg(time_spent) AS avg_time FROM tickets INNER JOIN users ON tickets.user_id = users.id INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE users.company_id = #{id} AND status_id !=4 GROUP BY user_id) as per_open_ticket
    	ON per_open_ticket.user_id = users.id LEFT JOIN 
    	(SELECT tickets.user_id, avg(time_spent) AS avg_time FROM tickets INNER JOIN users ON tickets.user_id = users.id INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE users.company_id = #{id} AND status_id = 1 GROUP BY user_id) as per_pending_ticket
    	ON per_pending_ticket.user_id = users.id LEFT JOIN 
    	(SELECT tickets.user_id, avg(time_spent) AS avg_time FROM tickets INNER JOIN users ON tickets.user_id = users.id INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE users.company_id = #{id} AND status_id = 3 GROUP BY user_id) as per_contacted_ticket
    	ON per_contacted_ticket.user_id = users.id LEFT JOIN
    	(SELECT user_id, count(*) AS count_high FROM tickets INNER JOIN users ON tickets.user_id = users.id WHERE users.company_id = #{id} AND priority_id = 1 GROUP BY user_id) as all_high_tickets
    	ON all_high_tickets.user_id = users.id LEFT JOIN
    	(SELECT user_id, count(*) AS count_all FROM tickets INNER JOIN users ON tickets.user_id = users.id WHERE users.company_id = #{id} GROUP BY user_id) as all_tickets
    	ON all_tickets.user_id = users.id 
    WHERE company_id = #{id} AND type='Employee'")
  end
  
  def total_open_tickets
    Company.find_by_sql("SELECT count(*) AS count_all FROM tickets INNER JOIN users ON tickets.user_id = users.id WHERE users.company_id = #{id} and status_id != 4").first.count_all
  end
  
  def total_tickets
    Company.find_by_sql("SELECT count(*) AS count_all FROM tickets INNER JOIN users ON tickets.user_id = users.id WHERE users.company_id = #{id}").first.count_all
  end
  
  def self.total_tickets
    Company.find_by_sql("SELECT count(*) AS count_all FROM tickets INNER JOIN users ON tickets.user_id = users.id INNER JOIN companies ON users.company_id = companies.id").first.count_all
  end
  
  def total_users
    Company.find_by_sql("SELECT count(*) AS count_all FROM users WHERE company_id = #{id}").first.count_all
  end
  
  def total_users_submit_tickets
    employees.delete_if { |u| u.tickets.length == 0 }.size
  end
end
