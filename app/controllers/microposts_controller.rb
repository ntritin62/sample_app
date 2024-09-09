class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach params.dig(:micropost, :image)
    if @micropost.save
      flash[:success] = t ".success"
      redirect_to root_url
    else
      @pagy, @feed_items = pagy current_user.feed.newest,
                                items: Settings.page_items
      render "static_pages/home",
             status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t ".success"
    return redirect_to root_path, status: :see_other if request.referer.nil?

    redirect_to request.referer, status: :see_other
  end

  private

  def micropost_params
    params.require(:micropost).permit Micropost::CREATE_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    redirect_to root_path, status: :see_other if @micropost.nil?
  end
end
