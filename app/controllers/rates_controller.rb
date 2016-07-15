class RatesController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, only: [:update]

  def create
    @rating = Rating.find(params[:rating_id])    
    return false if self_rate? @rating
    @post = @rating.post
    @rate = @rating.rate(current_user, params[:up] == 'true')
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
  end

  def update 
    @rate = Rate.find(params[:id])
    @rating = @rate.rating
    return false if self_rate? @rating
    @rate.toggle_up
    @post = @rating.post
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
  end

  def destroy
    @rating = Rating.find(params[:rating_id])
    return false if self_rate? @rating
    @post = @rating.post   
    @rating.unrate(current_user)
    respond_to do |format|
      format.html { redirect_to request.referrer || root_url }
      format.js
    end
  end

  private

    def correct_user
      if !Rate.exists? params[:id]
        redirect_to root_url
        return false
      end
      temp_user = Rate.find(params[:id]).user
      redirect_to(root_url) unless current_user?(temp_user)
    end

    def self_rate?(rating)
      if current_user? rating.post.user
        flash[:error] = "You cannot rate your own posts."
        redirect_to request.referrer || root_url
        return true
      else
        return false
      end
    end
end
