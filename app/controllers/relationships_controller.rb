class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:tracked_id])
    current_user.track(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).tracked
    current_user.untrack(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end