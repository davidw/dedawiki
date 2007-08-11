class PageController < ApplicationController

  include Differ

  caches_page :show

  # These methods must not be called with an empty title.
  before_filter(:check_for_empty_title,
                :only => [:history, :history_diff, :refer,
                          :create, :edit, :update, :dynamicshow])

  # These methods must be called with a title that does *not* exist.
  before_filter :page_doesnt_exist, :only => [:create, :newpage]

  def index
    show
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :update ],
         :redirect_to => { :action => :index }

  # This shows the page in question.
  def show
    if !Siteinfo.setup?
      redirect_to :controller => 'setup', :action => 'index'
      return
    end

    if params[:title].nil? || params[:title].length == 0
      redirect_to('/')
      return
    end

    @page = Page.find(:first, :conditions => ['title = ?', title_param])
    if @page.nil?
      redirect_to :action => 'create', :title => title_param
      return
    end

    @authors = {}
    addtotal = 0
    @page.revisions.each do |r|
      addtotal += r.addchars unless r.addchars.nil?
      @authors[r.user] ||= 0
      @authors[r.user] += r.addchars unless r.addchars.nil?
    end
    @authors.each do |k,v|
      if addtotal == 0
        @authors[k] = 0
      else
        @authors[k] = @authors[k].to_f / addtotal.to_f * 100
      end
    end

    render :action => 'show'
  end

  # This exists to get around the cache when updating/editing/creating
  # pages.
  def dynamicshow
    show
  end

  # Called via javascript to dynamically fill in the login div in the
  # upper right corner.  It's less work to only do that dynamically
  # rather than create the whole page.
  def lgn
    render(:layout => false)
  end

  # Starts the creation of a new page.
  def create
    @page = Page.new(:title => title_param)
  end

  # Actually creates a new page.
  def newpage
    @page = Page.new(params[:page])
    if @page.save
      add_revision(current_user, @page, request.remote_ip,
                   params[:revision][:comment])
      flash[:notice] = "#{@page.title} saved"

    end
    redirect_to(:action => 'dynamicshow', :title => @page.title)
  end

  # Show recently updated pages
  def recent
    @revisions = Revision.find_by_sql("select * from revisions where id in (select max(id) from revisions group by page_id) order by id desc limit 20");
  end

  # Atom feed of recent changes.
  def recent_atom
    recent()
    render :layout => false
  end

  # Shows all the pages that refer to the given page.
  def refer
    @page_title = title_param
    @pages = Page.find(:all,
                       :conditions => ['content like ?', "%[[#{@page_title}]]%"])
  end

  # Get revision history for a page.
  def history
    @page = Page.find_by_title(title_param)
    if @page.nil?
      render(:file => "#{RAILS_ROOT}/public/404.html",
             :status => '404 Not Found')
      return
    end

    if params[:revision].nil?
      @revision = @page.revisions.length
    else
      @revision = params[:revision].to_i
    end
    if @page.revisions.reverse[@revision - 1].nil?
      @revision_content = ""
    else
      @revision_content = @page.revisions.reverse[@revision - 1].content
    end
  end

  # Show the differences between two revisions
  def history_diff
    @title = "DedaWiki Page Revision Differences"

    @page = Page.find_by_title(title_param)
    if @page.nil?
      render(:file => "#{RAILS_ROOT}/public/404.html",
             :status => '404 Not Found')
      return
    end

    @old = params[:older].to_i
    @new = params[:newer].to_i

    if @old > @page.revisions.length || @new < 0
      redirect_to :action => 'history', :id => params[:id]
      return
    end

    newcontent = @page.revisions.reverse[@new - 1].content
    if @old > 0
      oldcontent = @page.revisions.reverse[@old - 1].content
    else
      oldcontent = ""
    end

    cachekey = "history-diff-#{@page.id}-#{@old}-#{@new}"
    cachedata = read_fragment(cachekey)

    if !cachedata
      @diff = DifferClass.new(Maruku.new(oldcontent).to_html, Maruku.new(newcontent).to_html).diffs
      cachedata = render(:layout => 'page')
      write_fragment(cachekey, cachedata)
    else
      render(:text => cachedata)
    end
  end

  # Edit a page.
  def edit
    @page = Page.find_by_title(title_param)
    if @page.nil?
      redirect_to(:controller => 'page', :action => 'show', :title => 'Home')
      return
    end
    if @page.content.nil?
      @page.content = Siteinfo.main.template
    end
  end

  # Update a page with a new edit.
  def update

    # Some spammers try and leave big long comments in their updates.
    # Catch them.
    spammer = nil
    if params[:revision] && params[:revision][:comment] && params[:revision][:comment].length > 250
      spammer = Spammer.new(:ip => request.remote_ip)
      spammer.save
    end

    # Add nasty anti spam things...
    if !spammer.nil? || Spammer.find_by_ip(request.remote_ip)
      redirect_to("http://#{request.remote_ip}")
      return
    end

    @page = Page.find_by_title(title_param)

    expire_page(:controller => 'page', :action => 'show', :title => @page.title)

    if @page.update_attributes(params[:page])
      add_revision(current_user, @page, request.remote_ip,
                   params[:revision][:comment])
      flash[:notice] = 'The page has been updated.'
      redirect_to :action => 'dynamicshow', :title => @page.title
    else
      render :action => 'edit'
    end
  end

  # Return results for search.
  def searchresults
    q = params[:q] || ""
    @results = Page.find(:all, :conditions =>
                         ["lower(title) like lower(?)", "%" + q + "%"],
                         :order => 'title')
  end

  private

  # Create a new revision and save it.
  def add_revision(user, page, ip, comment)
    r = Revision.new(:ip => ip, :content => page.content)
    r.user = user
    r.page = page
    r.comment = comment
    r.save!
  end

  # Check and make sure the title isn't empty.
  def check_for_empty_title
    if params[:title].nil? || params[:title].length == 0
      redirect_to('/')
      return false
    end
  end

  # Returns the :title param.
  def title_param
    t = params[:title]
    return "" if t.nil?
    return t if t.class == String
    return params[:title].join("/")
  end

  # Return false if the page *exists*
  def page_doesnt_exist
    title = title_param
    if title == "" && params[:page] && params[:page][:title]
      title = params[:page][:title]
    end
    page = Page.find(:first, :conditions => ['title = ?', title])
    if !page.nil?
      redirect_to :action => 'show', :title => page.title
      return false
    end
  end
end
