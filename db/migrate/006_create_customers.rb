class CreateCustomers < ActiveRecord::Migration
  def self.up
    create_table :customers do |t|
      t.column "name",              :string, :limit => 50
      t.column "address1",          :string, :limit => 100
      t.column "address2",          :string, :limit => 100
      t.column "city",              :string, :limit => 50
      t.column "state_id",          :integer
      t.column "zip",               :string, :limit => 10
      t.column "phone",             :string, :limit => 20
      t.column "fax",               :string, :limit => 20
      t.column "image_url",         :string, :limit => 250
      t.column "website",           :string, :limit => 200
      t.column "wiki",              :string, :limit => 200 
      t.column "maildomain",        :string, :limit => 80
      t.column "created_at",        :datetime
      t.column "updated_at",        :datetime
      t.column "turn_up",           :datetime
      t.column "vcio",              :datetime
      t.column "ceo_name",          :string, :limit => 50
      t.column "ceo_phone",         :string, :limit => 20
      t.column "contact_name",      :string, :limit => 50
      t.column "contact_phone",     :string, :limit => 20
      t.column "contracted_users",  :integer
    end
  end

  def self.down
    drop_table :customers
  end
end
