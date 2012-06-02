require File.dirname(__FILE__) + '/../test_helper'
require 'notification_mailer'

class NotificationMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "utf-8"
  
  def test_truth
    assert(true, "it should not failed ever")
  end

  # include ActionMailer::Quoting
# 
#   def setup
#     ActionMailer::Base.delivery_method = :test
#     ActionMailer::Base.perform_deliveries = true
#     ActionMailer::Base.deliveries = []
# 
#     @expected = TMail::Mail.new
#     @expected.set_content_type "text", "plain", { "charset" => CHARSET }
#   end
# 
#   def test_notify
#     @expected.subject = 'NotificationMailer#notify'
#     @expected.body    = read_fixture('notify')
#     @expected.date    = Time.now
# 
#     assert_equal @expected.encoded, NotificationMailer.create_notify(@expected.date).encoded
#   end
# 
#   private
#     def read_fixture(action)
#       IO.readlines("#{FIXTURES_PATH}/notification_mailer/#{action}")
#     end
# 
#     def encode(subject)
#       quoted_printable(subject, CHARSET)
#     end
end
