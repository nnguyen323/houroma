require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
	def setup
		@user = users(:michael)
		@activity = @user.activities.build(content: "Lorem ipsum", action_id: "1")
	end

	test "should be valid" do 
		assert @activity.valid?
	end

	test "user id should be present" do
		@activity.user_id = nil
		assert_not @activity.valid?
	end

	test "action id should be present" do
		@activity.action_id = nil;
		assert_not @activity.valid?
	end

	test "content should be at most 140 characters" do
		@activity.content = "a" * 141
		assert_not @activity.valid?
	end

	test "order should be most recent first" do
		assert_equal activities(:most_recent), Activity.first
	end
end
