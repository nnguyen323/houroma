class LoungesController < ApplicationController
  def show
    #newest
    @action = find_or_create_action(params[:action_name])
    @feed_items = @action.feed.paginate(page: params[:page], per_page: 30)
  end

  def top
    @action = find_or_create_action(params[:action_name])
    @feed_items = @action.top_new.paginate(page: params[:page], per_page: 30)
  end

  def active
    @action = find_or_create_action(params[:action_name])
    @feed_items = @action.active.paginate(page: params[:page], per_page: 30)
  end
end