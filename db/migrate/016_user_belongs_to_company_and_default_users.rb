class UserBelongsToCompanyAndDefaultUsers < ActiveRecord::Migration
  def self.up
    add_column "users", "company_id", :integer

    User.create(:first_name => "System",
                    :last_name => "Admin",
                    :password => "secret",
                    :email => "admin@example.com",
                    :company_id => 1)
  end

  def self.down
    remove_column "users", "company_id"
  end
end
