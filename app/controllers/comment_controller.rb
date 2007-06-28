class CommentController < ApplicationController

  before_filter :comment_login
  cache_sweeper :comment_sweeper, :only => [:create, :update]

  # Called initially when a user replies or creates a new comment.
  def reply
    @page = Page.find(params[:page])
    @parent_id = params[:parent]
    @comment_indent = params[:indent]
  end

  def create
    @comment = Comment.new(params[:comment])
    @page = Page.find(params[:page])
    @comment.page = @page
    @comment.user = current_user
    @comment.parent_id = params[:parent]
    @parent_id = @comment.parent_id
    @comment_indent = params[:indent].to_i
    if @comment.save
      flash[:notice] = "Comment added"
    else
      flash[:notice] = "Error creating new comment"
    end
  end

  def edit
    @comment = Comment.find(params[:id])
    @comment_indent = params[:indent]

    if @comment.user != current_user
      render(:text => "You can't edit other people's comments")
      return false
    end


    @parent_id = @comment.parent.nil? ? nil : @comment.parent.id
    @page = @comment.page
    render :layout => false

  end

  def update
    @comment = Comment.find(params[:id])
    @comment_indent = params[:indent].to_i
    @page = @comment.page

    if @comment.user != current_user
      render(:text => "You can't edit other people's comments")
      return false
    end

    if !@comment.update_attributes(params[:comment])
      render(:text => "You can't edit other people's comments")
      return false
    end
  end

  def cancel_edit
    @comment = Comment.find(params[:id])
    @parent_id = @comment.parent_id
    @comment_indent = params[:indent].to_i
    @page = @comment.page
  end

  def cancel_reply
    render :text => ''
  end

  private
  def comment_login
    ajax_login_required("You need to be <a href=\"/account/login\">logged in</a> to do this")
  end

end
