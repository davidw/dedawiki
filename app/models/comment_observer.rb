class CommentObserver < ActiveRecord::Observer

  # Walk the ancestors, and send email to those who have requested it.
  def after_create(comment)
    # Keep track of who we have already sent to, so as to avoid
    # repeats.
    emailed = {}

    comment.ancestors.each do |a|
      if a.user.email && a.emailupdates? && emailed[a.user.email].nil?
        # comment.logger.error "SEND EMAIL TO #{a.user.email}"
        Notifications.deliver_newcomment(a.user, comment)
        emailed[a.user.email] = 1
      end
    end
  end

end
