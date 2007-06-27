class UserMailer < ActionMailer::Base

  def welcome(user)
    @subject    = 'Welcome to ' + Siteinfo.main.name
    @body       = {}
    @recipients = user.email
    @from       = Siteinfo.main.email
    @sent_on    = Time.now
    @headers    = {}
  end

  def forgot_password(user, newpass)
    @subject    = Siteinfo.main.name + ': Password reset'
    @body       = {:newpass => newpass}
    @recipients = user.email
    @from       = Siteinfo.main.email
    @sent_on    = Time.now
    @headers    = {}
  end

  def changed_account_info(sent_at = Time.now)
    @subject    = Siteinfo.main.name + ': Account information update'
    @body       = {}
    @recipients = ''
    @from       = Siteinfo.main.email
    @sent_on    = sent_at
    @headers    = {}
  end
end
