class CommentSweeper < ActionController::Caching::Sweeper

  observe Comment

  def after_create(model)
  end

  def after_update(model)
  end

  def after_destroy(model)
  end

end
