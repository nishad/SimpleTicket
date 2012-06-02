class CreateDifficulties < ActiveRecord::Migration
  def self.up
    create_table "difficulties" do |t|
        t.column "name", :string
        t.column "level", :integer
    end
    
    [{:name => 'Tier I', :level => 1},
    {:name => 'Tier II', :level => 2},
    {:name => 'Tier III', :level => 3},].each do |params|
      Difficulty.create(params)
    end
  end

  def self.down
    drop_table "difficulties"
  end
end
