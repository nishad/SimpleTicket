class Engineer < User
  admin_company_id = 1

  has_many    :tickets
  belongs_to :engineer_role, :class_name => "Role"
  belongs_to :company, :conditions => ["id = ?", admin_company_id]

  attr_accessor :role

  def role
    self.engineer_role
  end

end
