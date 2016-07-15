class ActivitiesController < ApplicationController
	before_action :logged_in_user,   only: [:create, :destroy, :update]
	before_action :correct_user, 	 	 only: [:destroy, :update]
	before_action :correct_activity, only: [:update]
	
	def create
		@feed_items = current_user.feed.paginate(page: params[:page], per_page: 10)
		
		#if user is active he/she shouldn't be creating another activity!
		if current_user.active?
			render 'landing_pages/home'
			return false
		end

		@action_name = params[:activity][:content].scan(/#[a-zA-z]\w*/)

		if @action_name.count == 1
			@action_name = @action_name[0] 
			@action_name.slice!(0)
		else
			if @action_name.count > 1
				flash[:danger] = 'Only one topic is allowed (one #)';
			elsif @action_name.count == 0
				flash[:danger] = 'No topics are present (use # followed by at least one non number character)'
			end
			redirect_to request.referrer || root_url
			return false;
		end				

		@action = find_or_create_action(@action_name)

		if @action
			#if the action saves, we update the :action_id to be an integer
			params[:activity][:action_id] = @action.id
			@activity = current_user.activities.build(activity_params)
			@activity.create_rating

			if @activity.save
				#if action saves and activity saves set active to true
				current_user.active = true
				current_user.active_id = @activity.id
				current_user.save
				flash[:success] = "You are now active!"
				redirect_to current_user.activation_route ? "/lounges/#{@action.content}" : request.referrer || root_url
				return false
			else
				@activity.errors.full_messages.each do|message|
					flash[:danger] = message;
				end
			end
		end
		redirect_to request.referrer || root_url
	end

	def show
		@activity = Activity.find(params[:id])
	end

	def autocomplete
		if params[:query][0] == '#'
			params[:query].slice!(0)
		end
		render json: Action.search(params[:query], fields: [{content: :text_start}],
		 autocomplete: false, limit: 10).map { |action| '#' + action.content}
	end

	def update
		if current_user.active and current_user.activity == @activity
			current_user.active = false
			@feed_items = current_user.feed.paginate(page: params[:page], per_page: 10)					
			current_user.save
			@activity.finished_at = Time.now
			@activity.save
			flash[:success] = "Topic completed... your time has been recorded"		
		end
			redirect_to request.referrer || root_url
	end

	def destroy
		if current_user.active? and @activity == current_user.activity
			flash[:danger] = "Topics that are in progress can not be deleted. Press stop first."
			redirect_to request.referrer || root_url
			return false;
		end

		if @activity.destroy
			flash[:success] = "Activity deleted. Time removed for that instance"
		else
			flash[:danger] = "An error occurred while deleting. Could not delete."
		end
		redirect_to request.referrer || root_url
	end

	private

		def activity_params
			params.require(:activity).permit(:content, :picture, :action_id)
		end

		def correct_user
			@activity = current_user.activities.find_by(id: params[:id])
			redirect_to root_url if @activity.nil?
		end

		def correct_activity
			redirect_to root_url if @activity.id != current_user.active_id
		end
end
