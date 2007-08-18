class Notifications < ActionMailer::Base

  # Send information to the user about a new comment having arrived in
  # a thread the user participated in.
  def newcomment(user, comment)
    return if user.email.nil?
    si = Siteinfo.find :first
    name = si.name || "DedaWiki"
    @subject    = "#{si.name}: someone has posted to a discussion thread"
    # The site domain variable comes from comment_controller's 'create' method.
    @body       = {:wikiname => name, :comment => comment, :page => comment.page, :host => $SITE_DOMAIN}
    @recipients = user.email
    @from       = Siteinfo.main.email
    @sent_on    = Time.now
    @headers    = {}
  end
end
