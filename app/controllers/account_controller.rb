class AccountController < ApplicationController

  layout "page"

  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # If you want "remember me" functionality, add this before_filter to Application Controller
  before_filter :login_from_cookie

  def index
    redirect_to(:action => 'signup') unless logged_in? || User.count > 0
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token,
          :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default('/')
      flash[:notice] = "Logged in successfully"
      return
    end
    flash[:notice] = "Login/Password incorrect"
  end

  def signup
    @user = User.new(params[:user])
    return unless request.post?
    @user.save!
    self.current_user = @user
    redirect_back_or_default('/')
    flash[:notice] = "Thanks for signing up!"
    welcomemail = UserMailer.create_welcome(@user)
    UserMailer.deliver(welcomemail)
  rescue ActiveRecord::RecordInvalid
    render :action => 'signup'
  end
  
  def logout
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/')
  end

  def new_password
  end

  def reset_password
    session[:password_reset_attempts] ||= 0
    if session[:password_reset_attempts] > 5
      flash[:notice] = "Maximum number of tries ecceeded"
      redirect_to :controller => 'account', :action => 'signup'
    end

    u = User.new(params[:user])
    notfound = []
    realuser = nil

    if u.email != ""
      realuser = User.find :first, :conditions => [' email = ? ', u.email]
      if realuser.nil?
        flash[:notice] =  "No user with this email was found"
        redirect_to :action => 'new_password'
        session[:password_reset_attempts] += 1
      end
    end

    s = (rand * 1000000).to_i.to_s
    realuser.password = s
    realuser.password_confirmation = s
    realuser.save

    resetmail = UserMailer.create_forgot_password(realuser, s)
    UserMailer.deliver(resetmail)

    render :layout => 'page'
  end


end
