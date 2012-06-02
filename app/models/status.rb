class Status < ActiveRecord::Base
  has_many :tickets
  
  def self.open
    find_by_name("Open")
  end
  
  def self.closed
    find_by_name("Closed")
  end
end
