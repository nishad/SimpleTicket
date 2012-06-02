class RemoveLimitForPasswordHashInDatabase < ActiveRecord::Migration
  def self.up
    remove_column "engineers", "password_hash"
    remove_column "engineers", "login"
    add_column "engineers", "password_hash", :string
  end

  def self.down
    add_column "engineers", "login", :string, :limit => 40
  end
end
