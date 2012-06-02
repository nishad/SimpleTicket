class NotificationMailer < ActionMailer::Base

  def msend(eng)
    @subject    = 'NotificationMailer#notify'
    @body       = {}
    @recipients = eng.email
    @from       = eng.email
    @sent_on    = Time.now
    @headers    = {}
  end

  def opened(email,subj,engineer,user,ticket)
    @subject    = subj
    @body["user"]= user
    @body["engineer"]= engineer
    @body["email"]= email
    @body["ticket"]= ticket
    @recipients = email
    @from       = 'do-not-reply@architel.com'
  end

  def notified(email,subj,person,user,ticket,journal)
    @subject    = subj
    @body["user"]= user
    @body["person"]= person
    @body["email"]= email
    @body["ticket"]= ticket
    @body["journal"]= journal
    @recipients = email
    @from       = 'do-not-reply@architel.com'
  end

  def closed(email,subj,engineer,user,ticket)
    @subject    = 'Your ticket has been closed.'
    @body["user"]= user
    @body["engineer"]= engineer
    @body["email"]= email
    @body["ticket"]= ticket
    @recipients = email
    @from       = 'do-not-reply@architel.com'
  end

end
