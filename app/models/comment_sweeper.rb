class CommentSweeper < ActionController::Caching::Sweeper

  observe Comment

  def after_create(model)
    expire_page(:controller => 'page', :action => 'show', :title => model.page.title)
  end

  def after_update(model)
    expire_page(:controller => 'page', :action => 'show', :title => model.page.title)
  end

  def after_destroy(model)
    expire_page(:controller => 'page', :action => 'show', :title => model.page.title)
  end

end
