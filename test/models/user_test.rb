require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
  	@user = User.new(username: "hunter", email: "rexxar@gmail.com", password: "skillstone", password_confirmation: "skillstone")
  end

  test "authenticated? should return false for a user with nil digest" do
  	assert_not @user.authenticated?(:remember, '')
  end

  test "name should be present" do
    @user.username = ""
   	assert_not @user.valid?
  end

  test "name should not be too long" do
  	@user.username = "a" * 21
  	assert_not @user.valid?
	end

	test "email validation valid addresses" do
		valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
		valid_addresses.each do |valid_address|
			@user.email = valid_address
			assert @user.valid?, "#{valid_address.inspect} should be valid town"
		end
	end
	
	test "email validation invalid addresses" do
		invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@gmail..com]
		invalid_addresses.each do |invalid_address|
			@user.email = invalid_address
			assert_not @user.valid?, "#{invalid_address.inspect} should be invalid town"
		end
	end

	test "unique email town" do
		duplicate_user = @user.dup
		duplicate_user.email = @user.email.upcase
		@user.save
		assert_not duplicate_user.valid?
	end
  
	test "casetown" do
		invalid_email = User.new(username: "kappa", email: "REXXAR@gmail.com")
		@user.save
		assert_not invalid_email.valid?
	end

	test "password should be present (nonblank)" do
		@user.password = @user.password = @user.password_confirmation = " " * 6
		assert_not @user.valid?
	end

	test "password should have minimum length" do
		@user.password = @user.password_confirmation = "a" * 5
		assert_not @user.valid?
	end

	test "associated activities should be destroyed" do
		@user.save
		@user.activities.create!(content: "Lorem ipsum", action_id:  1)
		assert_difference 'Activity.count', -1 do
			@user.destroy
		end
	end

  test "should track and untrack a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.tracking?(archer)
    michael.track(archer)
    assert michael.tracking?(archer)
    assert archer.trackers.include?(michael)
    michael.untrack(archer)
    assert_not michael.tracking?(archer)    
  end

  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from followed user
    lana.activities.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # Posts from self
    assert michael.feed.include?(michael.activities.first)
    # Posts from unfollowed user
    archer.activities.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
