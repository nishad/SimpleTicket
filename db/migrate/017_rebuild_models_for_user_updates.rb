class RebuildModelsForUserUpdates < ActiveRecord::Migration
  def self.up
    remove_column :ticket_updates, :user_id
    remove_column :ticket_updates, :journal
    remove_column :tickets, :version
    execute 'ALTER TABLE ticket_updates CHANGE engineer_id user_id INTEGER'
  end

  def self.down
    add_column :ticket_updates, :user_id, :integer
    add_column :ticket_updates, :journal, :integer
    add_column :tickets, :version, :integer
    execute 'ALTER TABLE ticket_updates CHANGE user_id engineer_id INTEGER'
  end
end
