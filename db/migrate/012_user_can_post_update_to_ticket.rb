class UserCanPostUpdateToTicket < ActiveRecord::Migration
  def self.up
    add_column "ticket_updates", "user_id", :integer
  end

  def self.down
    remove_column "ticket_updates", "user_id"
  end
end
