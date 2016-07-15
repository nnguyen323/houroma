require 'test_helper'

class NestUsageTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @usernest = nests(:singnestmichael)
  end

  test "unsuccessful nest creation" do
    get nests_path
    assert_redirected_to login_path    
    assert_no_difference 'Nest.count'  do
        post nests_path, nest: { title: "tennis"}
    end
    assert_redirected_to login_path
    log_in_as(@user)
    assert_difference 'Nest.count', 1 do
        post nests_path, nest: { title: "actiondoesnotexist"}
    end
  end

  test "successful nest creation and" do
    log_in_as(@user)
    assert_difference 'Nest.count', 1  do
        post nests_path, nest: { title: "tennis"}
    end
    nest_to_delete = Nest.last
    assert_not flash.empty?
    get '/nests/tennis'
    assert_template 'nests/show'

    assert_difference 'Nest.count', 1  do
        post nests_path, nest: { title: "rockclimbing"}
    end

    #delete rockclimbing
    assert_difference 'Nest.count', -1 do
      delete nest_path(@user.nests.last)
    end

    #re add the one you just deleted
    assert_difference 'Nest.count', 1  do
        post nests_path, nest: { title: "rockclimbing"}
    end

    #try adding same tennis ...should fail
    assert_no_difference 'Nest.count' do
        post nests_path, nest: { title: "tennis"}
    end

    #login with different user and try to add same title...also try to delete one of other guys' nests
    delete logout_path
    log_in_as(@other_user)
    
    assert_difference 'Nest.count', 1  do
        post nests_path, nest: { title: "rockclimbing"}
    end

    assert_no_difference 'Nest.count' do
        delete nest_path nest_to_delete
    end
  end

  test "deleting nest deletes all the birds too" do
    assert_no_difference 'Bird.count' do
        delete nest_path @usernest
    end    

    log_in_as(@user)
    numbirds = @usernest.birds.count
    assert_difference 'Bird.count', -numbirds do
        delete nest_path @usernest
    end
  end

  test "illegal nest deletion" do
    assert_no_difference 'Nest.count' do
        post nests_path, nest: { title: "tennis"}
    end
    assert_not flash.empty?
  end
end