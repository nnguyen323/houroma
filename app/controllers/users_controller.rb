class UsersController < ApplicationController
	before_action :logged_in_user, 	only: [:edit, :update, :index, :destroy, :tracking, :trackers]
	before_action :correct_user,	 	only: [:edit, :update]
  before_action :admin_user, 			only:  [:destroy, :index]

	def show
		@user = User.find_by_username(params[:username])
		if @user
			@activities = @user.activities.paginate(page: params[:page], per_page: 10)
		else
			redirect_to root_url
		end
	end	
		
	def autocomplete
		render json: User.search(params[:query], 
		 fields: [{username: :text_start}],
		 autocomplete: false, limit: 10).map{ |user| 
			{username:user.username, picture:user.picture.thumb_tiny.url}
		}
	end
	
	def new
		@user = User.new
	end

	def index
		@users = User.paginate(page: params[:page])
		@activities = Activity.order('created_at ASC').limit(15)
	end

	def destroy
		User.find_by_username!(params[:username]).destroy
		flash[:success] = "User deleted"
		redirect_to users_url
	end

	def create
		@user = User.new(user_params)
		if @user.save
			@user.send_activation_email
			@user.track_admin
			flash[:info] = "Please check your email to activate this account."
			redirect_to root_url
		else
			render 'new'
		end
	end

	def edit
		@user = User.find_by_username!(params[:username])
	end

	def update
		@user = User.find_by_username!(params[:username])
		if !@user.authenticate(params[:user][:pass_prompt])
			flash[:danger] = "Incorrect password"
			redirect_to request.referrer || root_url
			return false;
		end
		if @user.update_attributes(user_params)
			flash[:success] = "Changes Saved"
			redirect_to @user
		else
			render 'edit'
		end
	end

	def tracking
		@title = "tracking"
		@user = User.find_by_username!(params[:username])
		@users = @user.tracking.paginate(page: params[:page], per_page: 10)
		render 'show_track'
	end

	def trackers
    @title = "trackers"
    @user  = User.find_by_username!(params[:username])
    @users = @user.trackers.paginate(page: params[:page], per_page: 10)
    render 'show_track'
  end

	private
		def user_params
			params.require(:user).permit(:username, :email, :password, :password_confirmation, :picture, :activation_route)
		end

		#confirms an admin user
		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end

		def correct_user
			@user = User.find_by_username!(params[:username])
			redirect_to(root_url) unless current_user?(@user)
		end
end
