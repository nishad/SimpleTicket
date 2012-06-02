class CreatePriorities < ActiveRecord::Migration
  def self.up
    create_table :priorities do |t|
      t.column "name",       :string, :limit => 60
      t.column "digit", :string, :limit => 10
    end
    
    Priority.create( [
    { :name => 'high',   :digit => 1 },
    { :name => 'low',    :digit => 2 }])
    
  end

  def self.down
    drop_table :priorities
  end
end
