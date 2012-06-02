class TicketStatistics < ActiveRecord::Migration
  def self.up
    create_table "statistics" do |t|
      t.column "user_id", :integer
      t.column "ticket_id", :integer
      t.column "pending_time", :float
      t.column "contacted_time", :float
      t.column "open_time", :float
      t.column "total_time", :float
    end
  end

  def self.down
    drop_table "statistics"
  end
end
