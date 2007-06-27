class SetupController < ApplicationController
  before_filter :only_setup_once

  layout 'page'

  def index
  end

  def setup
    @user = User.new(params[:user])
    @user.admin = true
    if !@user.save
      render :action => 'index'
      return
    end

    @siteinfo = Siteinfo.new(params[:siteinfo])
    if !@siteinfo.save
      @user.destroy
      render :action => 'index'
      return
    end
    Siteinfo.setup!
    self.current_user = @user
  end

  private
  def only_setup_once
    if Siteinfo.setup? && current_user.login != Siteinfo.main.adminlogin
      redirect_to '/'
      return false
    end
  end

end
