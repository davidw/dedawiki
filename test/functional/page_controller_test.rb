require File.dirname(__FILE__) + '/../test_helper'

class PageControllerTest < Test::Unit::TestCase
  fixtures :pages, :users, :revisions, :siteinfos

  def setup
    @controller = PageController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = pages(:first).id
    siteinfo = Siteinfo.new(:name => "Test Wiki", :tagline => 'A wiki to test',
                            :setup => true, :allowanonymous => true)
    siteinfo.save
  end

  def test_index
    get :index
    assert_response :redirect
    assert_redirected_to '/'
  end

  def test_show
    get :show, :title => 'Home'

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:page)
    assert assigns(:page).valid?
  end

  def test_create
    num_pages = Page.count

    post :create, :title => 'Newpage'

    assert_response :success

    assert_equal num_pages, Page.count
  end

  def test_create_existing_page
    num_pages = Page.count

    post :create, :title => 'Home'

    assert_response :redirect
    assert_redirected_to :action => 'show', :title => 'Home'
  end

  def test_newpage_existing_page
    num_pages = Page.count

    post(:newpage, :page => {:content => 'fiddle with home page', :title => 'Home'},
         :revision => {:comment => 'created new home page'})

    assert_response :redirect
    assert_redirected_to :action => 'show', :title => 'Home'
  end

  def test_newpage
    num_pages = Page.count

    post(:newpage, :page => {:content => 'a new page', :title => 'Newpage'},
         :revision => {:comment => 'created new page'})

    assert_response :redirect
    assert_redirected_to :action => 'dynamicshow', :title => 'Newpage'

    assert_equal num_pages + 1, Page.count
  end

  def test_edit
    get :edit, :title => 'Home'

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:page)
    assert assigns(:page).valid?
  end

  def test_edit_of_nonexistant_page
    get :edit, :title => 'WiggleWaggle'

    assert_response :redirect
    assert_redirected_to :action => 'show', :title => 'Home'
  end

  def test_update
    post(:update, :title => 'Home', :revision => {:comment => 'updated home'},
         :page => {:content => 'new improved home'})
    assert_response :redirect
    assert_redirected_to :action => 'dynamicshow', :title => 'Home'
  end

  def test_history
    get(:history, :title => 'Home')
    assert_response :success
  end

  def test_history_diff
    get(:history_diff, :title => 'Home', :older => 1, :newer => 2)
    assert_response :success
  end

  def test_history_diff_missing
    get(:history_diff, :title => 'Home', :older => 10, :newer => 20)
    assert_response :missing
  end

end
