class BirdsController < ApplicationController
before_action :logged_in_user, 	only: [:create]

	def create
		happynest = Nest.find(params[:bird][:nest_id])
		user = User.find_by_username(params[:bird][:user_id].downcase)
    
    if happynest.nil?
      flash[:danger] = "The nest you are trying to add a user to does not exist."
    elsif !current_user? happynest.user
      flash[:danger] = "You are trying to add a user to a nest that you do not own." 
    elsif user.nil?
      flash[:danger] = "This user does not exist!"
    elsif happynest.nesting? user
      flash[:info] = "#{user.username} is already nesting here."
    else
  		happynest.add_to_nest user
      flash[:success] = "#{user.username} has been added to your #{happynest.title} nest."     
    end
    redirect_to request.referrer || root_url
	end

  def destroy
    bird = Bird.find(params[:id])

    if bird
    #check if correct user is deleting the bird
      if !current_user? bird.nest.user
        flash[:danger] = "Don't try to delete users in a nest that doesn't belong to you."
      else    
        flash[:success] = "#{bird.user.username} was removed from #{bird.nest.title}"
        bird.destroy
      end
    else
      flash[:danger] = "Can't remove this user from the nest because the user doesn't exist in it."
    end
    redirect_to request.referrer || root_url
  end
end
