class MoveEngTypeToRoles < ActiveRecord::Migration

  class EngineerRole < Role
  end

  def self.up
    create_table :roles do |t|
      t.column :name, :string
      t.column :type, :string
    end
    add_column :users, :role_id, :integer

    EngineerRole.create :name => "Engineer"
    EngineerRole.create :name => "Manager"
    EngineerRole.create :name => "Administrator"
    execute "UPDATE users SET type='Engineer', role_id=3"
  end

  def self.down
  end
end
