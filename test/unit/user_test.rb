require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  # Replace this with your real tests.
  def test_truth
    assert true
  end
  
  def test_auth
    assert(User.authenticate("fake@address.dtl", "secret"), "Didn't Authenticate")
    assert_equal User.authenticate("nicolas@paton.com", "secret"), User.find_by_email("nicolas@paton.com")
    assert_raise(AuthenticationError) { User.authenticate("nicolas@paton.com", "not_secret") }
  end
  
  def test_password_setter
    uf = User.find_by_email("nicolas@paton.com")
    assert_equal User.authenticate("nicolas@paton.com", "secret"), uf
    uf.email, uf.password = "npatel@architel.com", ""
    assert(uf.save, "Saving Nicolas to Niket Failed")
    assert_raise(AuthenticationError) { User.authenticate("npatel@architel.com", "") }
    assert_equal User.authenticate("npatel@architel.com", "secret"), uf
    uf.password = "secret_is_not_secret_anymore"
    assert(uf.save, "Saving Npatel Failed with new password")
    assert_equal User.authenticate("npatel@architel.com", "secret_is_not_secret_anymore"), uf
  end
end
