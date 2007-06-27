class PageSweeper < ActionController::Caching::Sweeper

  observe Page

  def after_create(model)
  end

  def after_destroy(model)
  end

end
