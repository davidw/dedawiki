# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  require_library_or_gem "maruku" unless Object.const_defined?(:Maruku)

  def maruku(txt)
    txt.blank? ? "" : Maruku.new(txt).to_html
  end

  def login_status()
    spacebar = "&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;"
    unless logged_in?
      return link_to("Log in", :controller => 'account', :action => 'login') +
        spacebar +
        link_to("Sign up", :controller => 'account', :action => 'signup')
    else
      return link_to("My Page", :controller => 'userpages', :action => 'show', :id => current_user.id) +
        spacebar +
      link_to("Log out", :controller => 'account', :action => 'logout')
    end
  end

  def page_link(page)
    return link_to("#{page.title}", :action => 'show',
                   :title => page.title)
  end

  def user_link(user)
    return "<em>deleted user</em>" if user.nil?
    link_to(user.login, :controller => 'userpages', :action => 'show', :id => user.id)
  end

end
