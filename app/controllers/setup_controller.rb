class SetupController < ApplicationController
  before_filter :only_setup_once

  layout 'page'

  # Displays the initial setup page.
  def index
  end

  # Performs initial setup.
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

  # Don't let people run setup once it's already been run.
  def only_setup_once
    if Siteinfo.setup? && current_user.login != Siteinfo.main.adminlogin
      redirect_to '/'
      return false
    end
  end

end
