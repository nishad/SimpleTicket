class PruneTimeFromTickets < ActiveRecord::Migration
  def self.up
    remove_column :tickets, :time_spent
  end

  def self.down
    add_column :tickets, :time_spent, :integer
  end
end
