require 'digest/sha2'
class User < ActiveRecord::Base
  attr_accessor :password
  belongs_to    :company
  has_many      :ticket_updates
  validates_uniqueness_of :email, :on => :create
  validates_format_of :email,
                      :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
  validates_presence_of :first_name, :email, :password

  def full_name
    "#{first_name} #{last_name}"
  end
  
  def get_class
    if self.class == Employee
      "user"
    else
      self.class.to_s.downcase
    end
  end

  def self.statistics(offset=0, limit=10)
    self.find_by_sql("SELECT customers.name, count(users.id) as user_count FROM companies as customers left join users on customers.id=users.company_id GROUP BY customers.name ORDER BY customers.name LIMIT #{limit} OFFSET #{offset}")
  end

  def password=(pass)
    unless pass.blank?
      salt = [Array.new(6){rand(256).chr}.join].pack("m").chomp
      self.password_salt, self.password_hash = salt, Digest::SHA256.hexdigest(pass + salt)
      @password = pass
    end
  end

  def self.authenticate(email, password)
    user = find(:first, :conditions => ['email = ?', email])
    unless user.blank?
      if user.password_hash.nil? or Digest::SHA256.hexdigest(password + user.password_salt) == user.password_hash
        user.update_attributes(:last_login => Time.now.to_s(:db))
	user
      else
        raise AuthenticationError, "Invalid email and/or password"
      end
    else
      raise AuthenticationError, "Invalid email and/or password"
    end
  end
  
  # stats methods
  #
  def count_tickets
    Ticket.count(:conditions => "user_id = #{id}")
  end
   
  def count_open
    Ticket.count(:conditions => "user_id = #{id} and status_id = 2")
  end                                                               
                                                                    
  def count_pending                                                 
    Ticket.count(:conditions => "user_id = #{id} and status_id = 1")
  end                                                               
                                                                    
  def count_contected                                               
    Ticket.count(:conditions => "user_id = #{id} and status_id = 3")
  end                                                               
                                                                    
  def count_closed                                                  
    Ticket.count(:conditions => "user_id = #{id} and status_id = 4")
  end
  
  def time_spent
    Ticket.find_by_sql("SELECT sum(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end
  
  def time_spent_after_hours
    Ticket.find_by_sql("SELECT sum(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} AND updates.created_at >= date_sub(now(), interval 30 day) AND (extract(hour from updates.created_at) < 8 OR extract(hour from updates.created_at) > 17)").first.time_spent.to_f
  end                                                                                                                                                                           
                                                                                                                                                                                
  def avg_time_spent                                                                                                                                                            
    Ticket.find_by_sql("SELECT avg(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end                                                                                                                                                                          
                                                                                                                                                                                
  def time_spent_on_open                                                                                                                                                        
    Ticket.find_by_sql("SELECT sum(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} and tickets.status_id =2 AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end                                                                                                                                                                           
                                                                                                                                                                                
  def avg_time_spent_on_open                                                                                                                                                    
    Ticket.find_by_sql("SELECT avg(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} and tickets.status_id =2 AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end                                                                                                                                                                           
                                                                                                                                                                                
  def time_spent_on_pending                                                                                                                                                     
    Ticket.find_by_sql("SELECT sum(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} and tickets.status_id =1 AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end                                                                                                                                                                           
                                                                                                                                                                                
  def avg_time_spent_on_pending                                                                                                                                                 
    Ticket.find_by_sql("SELECT avg(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} and tickets.status_id =1 AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end                                                                                                                                                                           
                                                                                                                                                                                
  def time_spent_on_contected                                                                                                                                                   
    Ticket.find_by_sql("SELECT sum(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} and tickets.status_id =3 AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end
  
  def avg_time_spent_on_contected
    Ticket.find_by_sql("SELECT avg(updates.time_spent) AS time_spent FROM tickets INNER JOIN ticket_updates updates ON tickets.id = updates.ticket_id WHERE tickets.#{self.get_class}_id = #{id} and tickets.status_id =3 AND updates.created_at >= date_sub(now(), interval 30 day)").first.time_spent.to_f
  end

end

class AuthenticationError < StandardError ; end
