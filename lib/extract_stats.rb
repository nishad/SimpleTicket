#  extract_stats.rb
#  
#
#  Created by Niket Patel on 2006-10-28.
#  Copyright (c) 2006 Architel Holdings LLC. All rights reserved.
#

module ExtractStats

  def ExtractStats.perform(tickets)
    failed_ids = []

    tickets.each do |t|
      ot = []
      ltime = t.created_at
      updates = t.ticket_updates
      total_time = contacted_time = open_time = 0
      pending_time = nil
      lu = updates.first

      updates.each do |u|
        unless(u.action_id == 6 || u.user.class == Employee)
          pending_time = u.created_at - ltime unless pending_time
          contacted_time += u.created_at - ltime if lu.action_id == 2
          open_time += u.created_at - ltime if lu.action_id != 2
          total_time += u.created_at - t.created_at if u.action_id == 4
          ltime = u.created_at
          lu = u
        end
      end

      total_time = total_time.to_f + pending_time.to_f
      stat = Statistic.find_by_user_id_and_ticket_id(t.user.id, t.id) || Statistic.new
      stat.ticket_id = t.id
      stat.user_id = t.user.id
      stat.engineer_id = t.engineer_id
      stat.pending_time = pending_time.to_f
      stat.contacted_time = contacted_time.to_f
      stat.open_time = open_time.to_f
      stat.total_time = total_time.to_f

      if stat.save
        # log.info "extracted-#{t.id}"
        print "."
      else
        failed_ids << t.id
        print "F"
      end
    end
    puts
    if failed_ids.size > 0
      puts "following tickets are failed to fetch:\n"
      puts failed_ids.join(", ")
    end
  end
end