class StoreCleartextPasswordForEmployees < ActiveRecord::Migration
  def self.up
    add_column "users", "text_password", :string
  end

  def self.down
    remove_column "users", "text_password"
  end
end
