class CreateTickets < ActiveRecord::Migration
  
  def self.up
    create_table :tickets do |t|
      t.column "subject",         :string, :limit => 200
      t.column "user_id",         :integer
      t.column "created_at",      :datetime
      t.column "updated_at",      :datetime
      t.column "priority_id",     :integer
      t.column "status_id",       :integer
      t.column "engineer_id",     :integer
      t.column "body",            :text
      t.column "time_spent",      :integer
      t.column "version",         :integer
      t.column "difficulty_id",   :integer
    end
  end

  def self.down
    drop_table :tickets
  end
end
