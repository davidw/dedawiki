class UserpagesController < ApplicationController

  before_filter :login_required, :only => [:editinfo, :update,
                                           :cancel_editinfo, :changepassform, :savenewpass]

  def index
  end

  def show
    @user = User.find(params[:id])
    redirect_to :index if @user.nil?
    @comments = @user.comments.find(:all, :order => 'created_at desc', :limit => 5)
  end

  def editinfo
    @user = current_user
    render :layout => false
  end

  def cancel_editinfo
    @user = current_user
    render :layout=> false, :partial => 'aboutme'
  end

  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      render :layout => false, :partial => 'aboutme'
    end

  end

  def changepassform
    @user = current_user
    render :layout => false
  end

  def savenewpass
    @user = current_user
    if @user.update_attributes(params[:user])
      render :layout => false, :partial => 'changepassok'
    end
  end

  def cancel_newpass
    @user = current_user
    render :layout=> false, :partial => 'changepass'
  end

end
