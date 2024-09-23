class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_user, only: :create
  before_action :load_relationship, only: :destroy

  def create
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.turbo_stream
    end
  end

  def destroy
    @user = @relationship.followed
    current_user.unfollow(@user)
    redirect_to @user
    respond_to do |format|
      format.html{redirect_to @user, status: :see_other}
      format.turbo_stream
    end
  end

  private

  def handle_invalid_user
    flash[:danger] = t "relationships.invalid_user"
    redirect_to root_path
  end

  def load_user
    @user = User.find_by id: params[:followed_id]
    return @relationship unless @user.nil?

    handle_invalid_user
  end

  def load_relationship
    @relationship = Relationship.find_by id: params[:id]
    return @relationship unless @relationship.nil?

    handle_invalid_user
  end
end
