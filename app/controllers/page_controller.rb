class PageController < ApplicationController

  caches_page :show

  before_filter :check_for_empty_title, :only => [:history, :history_diff, :refer,
                                                  :create, :edit, :update, :dynamicshow]

  include Differ

  def index
    show
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :update ],
         :redirect_to => { :action => :index }

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

  def dynamicshow
    show
  end

  def lgn
    render :layout => false
  end

  def create
    @page = Page.new(:title => title_param)
  end

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

  def refer
    @page_title = title_param
    @pages = Page.find(:all,
                       :conditions => ['content like ?', "%[[#{@page_title}]]%"])
  end

  # Get revision history for a page.
  def history
    @page = Page.find_by_title(title_param)
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

  def edit
    @page = Page.find_by_title(title_param)
    if @page.content.nil?
      @page.content = Siteinfo.main.template
    end
  end

  def update
    # Add nasty anti spam things...
    if Spammer.find_by_ip(request.remote_ip)
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

  private
  def add_revision(user, page, ip, comment)
    r = Revision.new(:ip => ip, :content => page.content)
    r.user = user
    r.page = page
    r.comment = comment
    r.save!
  end

  def check_for_empty_title
    if params[:title].nil? || params[:title].length == 0
      redirect_to('/')
      return false
    end
  end

  def title_param
    t = params[:title]
    return t if t.class == String
    return params[:title].join("/")
  end

end
