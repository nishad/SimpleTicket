class EngineerRole < Role
  has_many :engineers, :class_name => "Role"

end
