class CreateStatuses < ActiveRecord::Migration
  def self.up
    create_table :statuses do |t|
      t.column "name", :string, :limit => 15
    end
    
    %w{ Pending Open Contacted Closed }.each do |status|
      Status.create( :name => status )
    end
  end

  def self.down
    drop_table :statuses
  end
end