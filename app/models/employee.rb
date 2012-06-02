class Employee < User
  belongs_to  :company
  has_many    :tickets, :foreign_key => 'user_id'
end
