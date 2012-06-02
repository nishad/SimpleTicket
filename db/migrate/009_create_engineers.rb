class CreateEngineers < ActiveRecord::Migration
  def self.up
    create_table :engineers do |t|
      t.column "first_name",        :string, :limit => 50
      t.column "last_name",         :string, :limit => 50
      t.column "login",             :string, :limit => 40
      t.column "password_hash",     :string, :limit => 40
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
    drop_table :engineers
  end
end
