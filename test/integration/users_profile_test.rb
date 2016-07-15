require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    log_in_as(@user, remember_me: '1')
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', "#{@user.username.capitalize} | Houroma"
    #assert_select 'h3', text: /^(#{Regexp.quote(@user.username)})\s*(#{Regexp.quote(@user.email)})$/
    assert_match @user.activities.count.to_s, response.body
    assert_select 'div.pagination'
    @user.activities.paginate(page: 1, per_page: 10).each do |activity|
      assert_match activity.content, response.body
    end
  end
end