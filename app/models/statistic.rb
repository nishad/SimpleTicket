require 'extract_stats'
class Statistic < ActiveRecord::Base
  def self.start_fetch
    tickets = Ticket.find(:all, :order => "created_at DESC", :conditions => "created_at >= date_sub(now(), interval 30 day)")
    ExtractStats.perform(tickets)
  end
end
