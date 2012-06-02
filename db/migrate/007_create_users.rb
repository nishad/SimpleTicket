class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.column "first_name",        :string, :limit => 50
      t.column "last_name",         :string, :limit => 50
      t.column "login",             :string, :limit => 40
      t.column "crypted_password",  :string, :limit => 40
      t.column "salt",              :string, :limit => 40
      t.column "email",             :string, :limit => 100
      t.column "phone",             :string, :limit => 20
      t.column "customer_id",       :integer
      t.column "role_id",           :integer
      t.column "created_at",        :datetime
      t.column "updated_at",        :datetime
    end
  end
    
  def self.down
    drop_table :users
  end
end
