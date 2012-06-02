class Action < ActiveRecord::Base
  has_many :ticket_updates
end
