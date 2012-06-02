class UserAccountMailer < ActionMailer::Base
  
  def after_signup(user)
    @subject          = "Your SimpleTicket account created"
    @body['email']    = user.email
    @body['password'] = user.text_password
    @body['name']     = user.full_name
    @recipients       = user.email
    @from             = 'do-not-reply@architel.com'
  end
end
