class SessionsController < ApplicationController
  before_action :find_user, only: :create
  def new; end

  def create
    unless @user.try :authenticate, params.dig(:session, :password)
      show_login_fail_msg
      return render :new, status: :unprocessable_entity
    end

    unless @user&.activated?
      show_not_activated_msg
      return render :new, status: :unprocessable_entity
    end

    params.dig(:session, :remember_me) == "1" ? remember(@user) : forget(@user)
    forwarding_url = session[:forwarding_url]
    log_in @user
    show_login_success_msg
    redirect_to forwarding_url || @user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url, status: :see_other
  end

  private
  def find_user
    @user = User.find_by(email: params.dig(:session, :email)&.downcase)
  end

  def show_login_success_msg
    flash[:success] = t ".successful"
  end

  def show_login_fail_msg
    flash.now[:danger] = t ".invalid"
  end

  def show_not_activated_msg
    flash.now[:danger] = t ".not_activated"
  end
end
