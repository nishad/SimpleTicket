class BigInMigrationMergeUsersEngineers < ActiveRecord::Migration
  def self.up
    drop_table "users"
    drop_table "engineers"
    create_table "users", :force => true do |t|
        t.column "first_name",        :string, :limit => 50
        t.column "last_name",         :string, :limit => 50
        t.column "password_hash",     :string
        t.column "password_salt",     :string, :limit => 40
        t.column "email",             :string, :limit => 100
        t.column "office_phone",      :string, :limit => 20
        t.column "cell_phone",        :string, :limit => 20
        t.column "home_phone",        :string, :limit => 20
        t.column "created_at",        :datetime
        t.column "updated_at",        :datetime
        t.column "status",            :string
        t.column "last_login",        :datetime
        t.column "type",              :string, :limit => 25
        t.column "instant_messaging", :string, :limit => 250
    end
  end

  def self.down
    create_table "engineers", :force => true do |t|
      t.column "first_name", :string, :limit => 50
      t.column "last_name", :string, :limit => 50
      t.column "password_salt", :string, :limit => 40
      t.column "email", :string, :limit => 100
      t.column "office_phone", :string, :limit => 20
      t.column "cell_phone", :string, :limit => 20
      t.column "home_phone", :string, :limit => 20
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
      t.column "status", :string
      t.column "last_login", :datetime
      t.column "type", :string, :limit => 25
      t.column "instant_messaging", :string, :limit => 250
      t.column "password_hash", :string
    end
    
    create_table "users", :force => true do |t|
      t.column "first_name", :string, :limit => 50
      t.column "last_name", :string, :limit => 50
      t.column "login", :string, :limit => 40
      t.column "crypted_password", :string, :limit => 40
      t.column "salt", :string, :limit => 40
      t.column "email", :string, :limit => 100
      t.column "phone", :string, :limit => 20
      t.column "customer_id", :integer
      t.column "role_id", :integer
      t.column "created_at", :datetime
      t.column "updated_at", :datetime
    end
  end
end
