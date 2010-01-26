# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem

  include ExceptionNotifiable

  def ajax_login_required(rejected_text)
    if !logged_in?
      @errtxt = rejected_text
      render(:controller => 'comments', :action => 'reply_not_logged')
      return false
    end
    return true
  end

  # Returns the :title param.
  def title_param
    t = params[:title]
    return "" if t.nil?
    return t if t.class == String
    return params[:title].join("/")
  end

  # Make sure the user is an admin.
  def admin_login_required
    if !logged_in? || !current_user.admin?
      redirect_to :controller => 'account', :action => 'login'
      return false
    end
  end

end
