class CreateTicketUpdates < ActiveRecord::Migration
  def self.up
    create_table :ticket_updates do |t|
      t.column "created_at",      :datetime
      t.column "comment",         :text
      t.column "engineer_id",     :integer
      t.column "ticket_id",       :integer
      t.column "time_spent",      :integer
      t.column "journal",         :text
      t.column "action_id",       :integer
      t.column "file",            :string, :limit => 150
    end
  end

  def self.down
    drop_table :ticket_updates
  end
end