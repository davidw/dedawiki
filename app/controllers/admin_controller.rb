class AdminController < ApplicationController

  cache_sweeper :page_sweeper, :only => [:delete]

  layout 'page'

  before_filter :admin_login_required

  def index
  end

  def config
    @siteinfo = Siteinfo.main
  end

  def config_update
    @siteinfo = Siteinfo.main
    if !@siteinfo.update_attributes(params[:siteinfo])
      render :action => 'config'
      return
    end
    flash[:notice] = "Site configuration updated"
    redirect_to :action => 'index'
  end

  # This needs to be improved - culling revisions as well as the page,
  # and accepting a title.
  def delete
    begin
      @page = Page.find(params[:delete_id])
      @page.destroy
    rescue => e
      @errmsg = "Page not found"
      render :action => 'error', :layout => false
      return
    end
    render :layout => false
  end

  def rollback
    @page = Page.find(params[:id])
    @good = params[:old].to_i
    @bad = @good + 1

    @goodrev = @page.revisions.reverse[@good - 1]
    @badrev = @page.revisions.reverse[@bad - 1]

    @page.content = @goodrev.content
    @page.save

    @spammer = Spammer.new(:ip => @badrev.ip)
    @spammer.save

    @page.revisions.reverse[@bad - 1 .. -1].each do |r|
      logger.info "Destroying revision: #{r.inspect}"
      r.destroy
    end

    expire_fragment(/history-diff-#{@page.id}-.*/)
  end

  private
  def admin_login_required
    return false if !logged_in?
    return false if !current_user.admin?
  end
end
