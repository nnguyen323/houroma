class LandingPagesController < ApplicationController
	def home
		@total_live_users = Activity.where("finished_at IS NULL").count

		if logged_in?
			@feed_items = current_user.feed.paginate(page: params[:page], per_page: 10)
		end
	end

	def help
	end

	def about
	end

	def contact
	end

	def search_all
		if params[:display][0] == "#"
			action = find_or_create_action(params[:display][1..-1])
			
			if action
				redirect_to "/lounges/#{action.content}"
			else
				flash.discard[:danger] = "The topic #{params[:display]} does not exist"
				redirect_to request.referrer || root_url
			end
		else
			existing_user = User.find_by_username(params[:display])

			if existing_user
				redirect_to user_path(existing_user)
			else
				flash.discard[:danger] = "The user #{params[:display]} does not exist"
				redirect_to request.referrer || root_url
			end
		end
	end
end
