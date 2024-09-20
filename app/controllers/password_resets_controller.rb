class PasswordResetsController < ApplicationController
  before_action :load_user, :valid_user, :check_expiration,
                only: %i(update edit)
  def new; end

  def edit; end

  def create
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".check_email"

      redirect_to root_url
    else
      flash.now[:danger] = t ".invalid_user"
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if params.dig(:user, :password).empty?
      @user.errors.add :password, t(".cannot_empty")
      return render :edit, status: :unprocessable_entity
    end

    if @user.update user_params
      log_in @user
      @user.update_column :reset_digest, nil
      flash[:success] = t ".reset_success"
      return redirect_to @user
    end

    render :edit, status: :unprocessable_entity
  end

  private

  def user_params
    params.require(:user).permit User::RESET_PARAMS
  end

  def load_user
    return if @user = User.find_by(email: params[:email])

    flash[:danger] = t "password_resets.invalid_email"
    redirect_to root_path
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "password_resets.expired_link"
    redirect_to root_path
  end

  def valid_user
    return if @user.activated? && @user.try(:authenticated?, "reset",
                                            params[:id])

    flash[:danger] = t "password_resets.invalid_user"
    redirect_to root_path
  end
end
