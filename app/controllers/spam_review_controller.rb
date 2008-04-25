class SpamReviewController < ApplicationController

  before_filter :admin_login_required

  def index
    if params[:all]
      @revisions = Revision.find(:all)
    else
      @revisions = Revision.find(:all, :conditions => 'not confirmed')
    end
  end

  def classify
    revisions = []
    params[:revid].each do |id|
      revisions << Revision.find(id)
    end

    if params[:confirm]
      revisions.each do |rev|
        rev.confirmed = true
        rev.save!
      end
    elsif params[:spam]
      revisions.each do |rev|
        sf = SpamFilter.instance
        res = sf.spam(rev, :content, :ip, :comment)
        rev.spam = true
        rev.confirmed = true
        rev.save!
      end
      redistribute_pages(revisions)
    elsif params[:ham]
      revisions.each do |rev|
        sf = SpamFilter.instance
        res = sf.ham(rev, :content, :ip, :comment)
        rev.spam = false
        rev.confirmed = true
        rev.save!
      end
      redistribute_pages(revisions)
    else
      flash[:notice] = "No option selected"
    end

    redirect_to :action => 'index'
  end

  private

  # Since some of the pages are spam, and we thought they weren't,
  # we're going to have to back those up.  Perhaps there is a cleaner
  # algorithm, but for the moment we just look through all the
  # affected pages, and fetch the last one that isn't spam, and call
  # it good.
  def redistribute_pages(revisions)
    pages = revisions.collect { |r| r.page }
    Page.transaction do
      pages.uniq.each do |page|
        lastgood = page.revisions.find(:all, :order => 'created_at desc',
                                       :limit => 1, :conditions => 'not spam').first
        if lastgood
          lastgood.page.content = lastgood.content
          lastgood.page.save
          expire_page(:controller => 'page', :action => 'show', :title => lastgood.page.title)
        else
          expire_page(:controller => 'page', :action => 'show', :title => page.title)
          page.destroy
        end
      end
    end
  end

end
