require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @non_admin = users(:archer)
    @admin = users(:michael)
  end

  test "no index for non-admin" do
    log_in_as(@non_admin)
    get '/userlist'
    assert_redirected_to root_url
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get '/userlist'
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.username
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get '/userlist'
    assert_select 'a', text: 'delete', count: 0
  end

end
