class Customer < Company
  has_many    :tickets, :through => :employees do
    def open
      self.count(:all, :conditions => 'status_id != 4')
    end

    def open_under_5_days
      self.count(:all, :conditions => "status_id != 4 AND created_at > \'#{5.days.ago.to_s(:db)}\'")
    end

    def closed
      self.count(:all, :conditions => 'status_id = 4')
    end
  end
  
  def map
    attributes = %w{address1 address2 zip city}.collect do |value|
      self["#{value}"]
    end
    query_attributes = attributes.join("+")
    query = "http://maps.google.com/maps?f=q&hl=en&sll=32.783333,-96.8&sspn=0.133063,0.346069&q=#{query_attributes}&ie=UTF8&om=1"
  end
  
  def tickets_past_30_days
      Ticket.count(:all, :conditions => "tickets.created_at >= \'#{Time.now.months_ago(1).to_s(:db)}\' AND company_id = #{self.id}", :include => :user) || 0
  end
  
  def minutes_past_30_days
    TicketUpdate.sum(:time_spent, :conditions => "ticket_updates.created_at >= \'#{Time.now.months_ago(1).to_s(:db)}\' AND company_id = #{self.id}", :joins => "LEFT JOIN tickets on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id") || 0
  end

private
  def self.statistics
    self.find_by_sql("SELECT companies.id, companies.name, user_count,
opencount.opencount as OpenTickets, prodless5days.Total as TotalOpenFrom5Days, prodless5days.Past5 as StillOpenFrom5Days, prodless5days.Past5Perc, closedpast30.count as Past30DaysClosed, closedprev30.count as Prev30DaysClosed, hoursprev30.hoursprev30 as Prev30Hours, engineerspast30.count as Past30DaysEngineers, avgopenpast30.OpenHrs as Past30AvgTimeToClose, avgpendingpast30.PendingAvg as Past30PendingAvg, avgpendingpast30.PendingMax as Past30PendingMax, avgpendingpast30.PendingMin as Past30PendingMin, over30past30.Count as Past30PendingOver30, over30prev30.Count as Prev30PendingOver30, afterhours.AfterHoursCount as AfterHours, afterhours.AllTicketsCount as AfterHourTickets, afterhours.AfterHoursPercent
FROM
companies LEFT JOIN
	(select companies.id as clientid, count(tickets.id) as opencount from tickets left join users on tickets.user_id=users.id left join companies on users.company_id=companies.id where status_id!=4 group by name order by companies.id) as opencount
ON opencount.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, alltickets.count as Total, prev5.count as Past5, (prev5.count / alltickets.count)*100 as Past5Perc from companies left join (select company_id, count(distinct(tickets.id)) as count from tickets inner join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id where action_id=6 and unix_timestamp(now())-unix_timestamp(ticket_updates.created_at)>432000 group by company_id) as alltickets on alltickets.company_id=companies.id left join (select company_id, count(distinct(tickets.id)) as count from tickets inner join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id where action_id=6 and unix_timestamp(now())-unix_timestamp(ticket_updates.created_at)>432000 and status_id<>4 group by company_id) as prev5 on prev5.company_id=companies.id order by clientid) as prodless5days
ON prodless5days.clientid=companies.id LEFT JOIN
	(select company_id as clientid, count(distinct(tickets.id)) as count from tickets inner join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id where action_id=4 and status_id=4 and ticket_updates.created_at>=date_sub(now(), interval 30 day) group by clientid) as closedpast30
ON closedpast30.clientid=companies.id LEFT JOIN
	(select company_id as clientid, count(distinct(tickets.id)) as count from tickets inner join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id where action_id=4 and status_id=4 and ticket_updates.created_at<date_sub(now(), interval 30 day) and ticket_updates.created_at>=date_sub(now(),interval 60 day) group by clientid) as closedprev30
ON closedprev30.clientid=companies.id LEFT JOIN
	(select company_id as clientid, sum(time_spent/60) as hoursprev30 from tickets left join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id where ticket_updates.created_at<date_sub(now(), interval 30 day) and ticket_updates.created_at>=date_sub(now(),interval 60 day) group by clientid) as hoursprev30
ON hoursprev30.clientid=companies.id LEFT JOIN
	(select uclient.company_id as clientid, count(distinct(ticket_updates.user_id)) as count from tickets left join ticket_updates on tickets.id=ticket_updates.ticket_id left join users as uclient on tickets.user_id=uclient.id left join users ueng on ticket_updates.user_id=ueng.id and ueng.company_id=1 where ueng.company_id=1 and ticket_updates.created_at>=date_sub(now(),interval 30 day) group by clientid) as engineerspast30
ON engineerspast30.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, avg( (unix_timestamp(timeclose.created_at)-unix_timestamp(timeopen.created_at))/60/60 ) as OpenHrs from tickets inner join (select closed.id as ticket_id, cjrnl.created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=6 and cjrnl.created_at>=date(date_sub(now(),interval 30 day))) as timeopen on tickets.id=timeopen.ticket_id inner join (select closed.id as ticket_id, cjrnl.created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=4 and cjrnl.created_at>=date(date_sub(now(),interval 30 day))) as timeclose on tickets.id=timeclose.ticket_id left join users on tickets.user_id=users.id left join companies on users.company_id=companies.id group by clientid) as avgopenpast30
ON avgopenpast30.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, avg(over30.pendtime) as PendingAvg, max(over30.pendtime) as PendingMax, min(over30.pendtime) as PendingMin from (select company_id, tickets.id, timeopen.created_at, timetaken.created_at, (unix_timestamp(timetaken.created_at)-unix_timestamp(timeopen.created_at))/60 as pendtime from tickets inner join (select closed.id as ticket_id, cjrnl.created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=6 and cjrnl.created_at>=date(date_sub(now(),interval 30 day))) as timeopen on tickets.id=timeopen.ticket_id left join (select closed.id as ticket_id, min(cjrnl.created_at) as created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=5 and cjrnl.created_at>=date(date_sub(now(),interval 30 day)) group by ticket_id) as timetaken on tickets.id=timetaken.ticket_id left join users on tickets.user_id=users.id) as over30 left join companies on over30.company_id=companies.id group by clientid) as avgpendingpast30
ON avgpendingpast30.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, count(distinct(over30.id)) as Count from (select company_id, tickets.id, timeopen.created_at, timetaken.created_at, (unix_timestamp(timetaken.created_at)-unix_timestamp(timeopen.created_at))/60 as pendtime from tickets inner join (select closed.id as ticket_id, cjrnl.created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=6 and cjrnl.created_at>=date(date_sub(now(),interval 30 day))) as timeopen on tickets.id=timeopen.ticket_id left join (select closed.id as ticket_id, min(cjrnl.created_at) as created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=5 and cjrnl.created_at>=date(date_sub(now(),interval 30 day)) group by ticket_id) as timetaken on tickets.id=timetaken.ticket_id left join users on tickets.user_id=users.id) as over30 left join companies on over30.company_id=companies.id where over30.pendtime>30 group by clientid) as over30past30
ON over30past30.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, count(distinct(over30.id)) as Count from (select company_id, tickets.id, timeopen.created_at, timetaken.created_at, (unix_timestamp(timetaken.created_at)-unix_timestamp(timeopen.created_at))/60 as pendtime from tickets inner join (select closed.id as ticket_id, cjrnl.created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=6 and cjrnl.created_at<date(date_sub(now(),interval 30 day)) and cjrnl.created_at>=date_sub(now(), interval 60 day)) as timeopen on tickets.id=timeopen.ticket_id left join (select closed.id as ticket_id, min(cjrnl.created_at) as created_at from tickets as closed inner join ticket_updates as cjrnl on closed.id=cjrnl.ticket_id where closed.status_id=4 and cjrnl.action_id=5 and cjrnl.created_at<date(date_sub(now(),interval 30 day) and cjrnl.created_at>=date_sub(now(), interval 60 day)) group by ticket_id) as timetaken on tickets.id=timetaken.ticket_id left join users on tickets.user_id=users.id) as over30 left join companies on over30.company_id=companies.id where over30.pendtime>30 group by clientid) as over30prev30
ON over30prev30.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, AfterHoursCount, AllTicketsCount, (AfterHoursCount/AllTicketsCount)*100 as AfterHoursPercent from companies left join (select company_id, count(distinct(tickets.id)) as AfterHoursCount from tickets left join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id left join companies on users.company_id=companies.id where action_id=6 and ticket_updates.created_at>=date_sub(now(), interval 30 day) and (weekday(ticket_updates.created_at)>4 or(time(ticket_updates.created_at)<'08:00:00' and time(ticket_updates.created_at)>'17:00:00')) group by company_id) as afterhrs on companies.id=afterhrs.company_id left join (select company_id, count(distinct(tickets.id)) as AllTicketsCount from tickets inner join ticket_updates on tickets.id=ticket_updates.ticket_id left join users on tickets.user_id=users.id where action_id=6 and ticket_updates.created_at>=date_sub(now(), interval 30 day) group by company_id) as alltickets on companies.id=alltickets.company_id group by clientid) as afterhours
ON afterhours.clientid=companies.id LEFT JOIN
	(select users.company_id as clientid, count(users.id) as user_count from users group by company_id) as usercounts
ON usercounts.clientid=companies.id LEFT JOIN
	(select companies.id as clientid, tickets from companies, (select count(tickets.id) as tickets from tickets left join ticket_updates on tickets.id=ticket_updates.ticket_id where ticket_updates.created_at>=date_sub(now(), interval 30 day) and action_id=6) as totaltix) as tickets
ON tickets.clientid=companies.id
ORDER BY companies.name")
  end

end
