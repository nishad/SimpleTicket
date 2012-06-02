class CreateActions < ActiveRecord::Migration
  def self.up
    create_table :actions do |t|
      t.column "name", :string, :limit => 40 
    end
    
    ['Update Ticket', 'Move to Contacted', 'Move to Schedule On-Site', 'Close Ticket', 'Reassigned'].each do |action_name|
      Action.create(:name => action_name)
    end
  end

  def self.down
    drop_table :actions
  end
end
