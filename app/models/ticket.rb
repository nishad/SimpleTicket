class Ticket < ActiveRecord::Base
  acts_as_taggable

  belongs_to :engineer
  belongs_to :user
  belongs_to :status
  belongs_to :priority
  belongs_to :difficulty
  validates_presence_of :user, :on => :create, :message => "should be selected"
  validates_presence_of :subject, :on => :create, :message => "can't be blank"
  validates_presence_of :body, :on => :create, :message => "can't be blank"
  has_many   :ticket_updates, :order => 'ticket_updates.created_at'

  attr_reader :priority
#  validates_presence_of :user, :subject, :body

  def age_since_creation
    age Time.now.to_i - self.created_at.to_i
  end

  def age_since_last_update
    age Time.now.to_i - self.updated_at.to_i
  end

  def priority
    if self.priority_id == 1
      "high"
    else
      "low"
    end
  end

  def simple_status
    if self.status_id == 1 and self.created_at > 30.minutes.ago
      "pending"
    elsif self.status_id == 1 and self.created_at <= 30.minutes.ago
      "pending_over_30min"
    elsif self.status_id == 3 and self.updated_at > 24.hours.ago
      "contacted"
    elsif self.status_id == 3 and self.updated_at <= 24.hours.ago
      "contacted_over_24h"
    elsif self.status_id == 2
      "open"
    elsif self.status_id == 4
      "closed"
    else
      ""
    end
  end

  def self.search(params=nil)
    unless params.nil? or params == ""
      query = []
      query << "tickets.engineer_id = #{params[:engineer_id]}" unless (params[:engineer_id].nil? || params[:engineer_id] == "0")
      query << "tickets.priority_id = #{params[:priority_id]}" unless (params[:priority_id].nil? || params[:priority_id] == "0")
      if params[:status_id] == 'open'
        query << "tickets.status_id != 4"
      else
        query << "tickets.status_id IN (#{params[:status_id]})" unless (params[:status_id].nil? || params[:status_id] == "0")
      end
      query << "tickets.updated_at < \'#{params[:updated_before]}\'" unless params[:updated_before].nil?
      unless (params[:search_field].nil? || params[:search_field] == "" || params[:search_field] == "\n")
        query << "((tickets.subject LIKE \'%#{params[:search_field]}%\' OR tickets.body LIKE \'%#{params[:search_field]}%\') OR (ticket_updates.comment LIKE \'%#{params[:search_field]}%\'))"
      end
      unless (params[:customer_id].nil? || params[:customer_id] == "0")
        query << "users.company_id = #{params[:customer_id]}"
      end

      query = query.join(' AND ')
      return query
    end
  end
    
  # change_status(Status.find_by_name("Open").id)
  def method_missing(method_id, *arguments)
    if mdata = /status_to_(open|closed|contacted|pending)/.match(method_id.to_s)
      status = mdata.captures.first
      change_status(Status.find_by_name(status.capitalize).id)
    else
      super
    end
  end
  
  def change_status(status)
    self.write_attribute(:status_id, status)
  end

  private
  def age(difference)
    #going to days, hours and minutes
    minutes_to_add = difference.div(60)
    minutes = minutes_to_add.modulo(60)
    hours_to_add = minutes_to_add.div(60)
    hours = hours_to_add.modulo(24)
    days = hours_to_add.div(24)

    # This is what is rendered
    "#{days}d|#{hours}h|#{minutes}m"
  end
end

