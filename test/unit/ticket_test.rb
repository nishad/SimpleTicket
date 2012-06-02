require File.dirname(__FILE__) + '/../test_helper'

class TicketTest < Test::Unit::TestCase
  fixtures :tickets

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_simple_status
    assert_equal Ticket.find(1).simple_status, "pending_over_30min"
    assert_equal Ticket.find(2).simple_status, "closed"
    assert_equal Ticket.find(3).simple_status, "pending_over_30min"
    assert_equal Ticket.find(4).simple_status, "pending"
    assert_equal Ticket.find(5).simple_status, "contacted"
    assert_equal Ticket.find(6).simple_status, "contacted_over_24h"
    assert_equal Ticket.find(7).simple_status, "pending"
    assert_equal Ticket.find(8).simple_status, "open"
    assert_equal Ticket.find(9).simple_status, ""
  end
  
  def test_age
    assert Ticket.find(1).age_since_creation.include?("3d|")
    assert Ticket.find(3).age_since_creation.include?("0d|0h")
    assert Ticket.find(5).age_since_last_update.include?("0d|20h|0m")
    assert Ticket.find(6).age_since_last_update.include?("1d|0h")
  end
end
