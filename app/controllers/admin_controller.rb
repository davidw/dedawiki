class AdminController < ApplicationController

  cache_sweeper :page_sweeper, :only => [:delete]

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

  # Delete a page and all its revisions.
  def delete
    @page = Page.find_by_title(title_param)
    @spammer = nil
    @page.destroy
    expire_page(:controller => 'page', :action => 'show', :title => @page.title)
  end

  # Delete a page, all its revisions, and mark the author of the last
  # revision a spammer.
  def delete_spam
    @page = Page.find_by_title(title_param)

    @spammer = Spammer.new(:ip => @page.revisions[0].ip)
    @spammer.save

    @page.destroy
    expire_page(:controller => 'page', :action => 'show', :title => @page.title)
    render :action => 'delete'
  end

  # Roll back to an older version.
  def rollback_not_spam
    # Used in the spam rollback
    @ips = []

    @page = Page.find(params[:id])
    @good = params[:old].to_i
    @bad = @good + 1

    @goodrev = @page.revisions.reverse[@good - 1]
    @badrev = @page.revisions.reverse[@bad - 1]

    @page.content = @goodrev.content
    @page.save

    @page.revisions.reverse[@bad - 1 .. -1].each do |r|
      @ips << r.ip
      logger.info "Destroying revision: #{r.inspect}"
      r.destroy
    end

    expire_fragment(/history-diff-#{@page.id}-.*/)
    expire_page(:controller => 'page', :action => 'show', :title => @page.title)
  end

  def rollback
    rollback_not_spam
    @ips.each do |ip|
      @spammer = Spammer.new(:ip => ip)
      @spammer.save
    end
  end

  private

end
