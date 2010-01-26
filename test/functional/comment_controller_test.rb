require 'test_helper'

class CommentControllerTest < ActionController::TestCase
  fixtures :comments, :users, :pages, :siteinfos

  def setup
    @controller = CommentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end

  # Test comment creation.
  def test_notification
    login_as :quentin

    num_comments = Comment.count
    post :create, :comment => {:content => 'I agree', :emailupdates => '1'}, :page => 1, :parent => 1
    assert_response :success
    assert_equal num_comments + 1, Comment.count
  end

end
