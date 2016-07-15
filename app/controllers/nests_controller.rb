class NestsController < ApplicationController
  before_action :logged_in_user,  only: [:create, :index, :show, :destroy]
  # before_action :correct_user,    only: [:show]

  def index
    @nests = current_user.nests
  end

  def show
    @nest = current_user.nests.find_by_title(params[:title])
    if !@nest
      redirect_to root_url
    end
  end

  def create
    params[:nest][:title] = params[:nest][:title].tr('#','').downcase
    @action = find_or_create_action(params[:nest][:title])
    
    if @action
      params[:nest][:title] = @action.content
      params[:nest][:action_id] = @action.id
      @nest = current_user.nests.find_by_title(params[:nest][:title])
      if !@nest
        @nest = current_user.nests.build(nest_params)
        @nests = current_user.nests
        if @nest.save
          @nest.add_to_nest(current_user)
          flash.now[:success] = "#{params[:nest][:title].capitalize} nest successfully created"

          redirect_to @nest
        else
          flash.now[:danger] = "Could not create the nest."
          render 'index'
        end
      else
        redirect_to @nest || root_url
      end
    else
      flash[:danger] = "Invalid nest Name: #{params[:nest][:title]}"      
      redirect_to request.referrer || root_url
    end
  end

  def destroy
    nest = current_user.nests.find_by_title(params[:title])
    if nest
      if current_user? nest.user
        nest.destroy
        flash[:success] = "#{params[:title].capitalize} nest deleted"
      else
        flash[:danger] = "Only delete your own nests"
      end
    else
      flash[:danger] = "#{params[:title].capitalize} doesn't exist"
    end
    redirect_to nests_url
  end

  private
  
    def nest_params
      params.require(:nest).permit(:action_id,:title)
    end
end
