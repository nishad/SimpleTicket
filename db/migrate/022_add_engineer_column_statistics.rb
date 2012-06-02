class AddEngineerColumnStatistics < ActiveRecord::Migration
  def self.up
    add_column "statistics", "engineer_id", :integer
  end

  def self.down
    remove_column "statistics", "engineer_id"
  end
end
