class CommentsController < ApplicationController
	def create
		@comment = current_user.comments.build(comment_params)

		if @comment.parent
			if current_user? @comment.parent.user 
				redirect_to request.referrer || root_url
				return false
			end
			@comment.depth = @comment.parent.depth + 1
		else
			@comment.depth = 0
		end
		
		@comment.create_rating
		
		unless @comment.save
			
		end
		redirect_to request.referrer || root_url
	end

	private
		def comment_params
			params.require(:comment).permit(:content, :parent_id, :activity_id)
		end
end
