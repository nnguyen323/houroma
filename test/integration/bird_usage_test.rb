require 'test_helper'

class BirdUsageTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @usersingnest = nests(:singnestmichael)
    @usershipnest = nests(:shipnestmichael)
    @singbirdone = birds(:singbirdone)
    @singbirdtwo = birds(:singbirdtwo)
  end

  test "test successful bird creation" do
    log_in_as(@user)
    assert_difference 'Bird.count', 1  do
      post birds_path, bird: { nest_id: @usershipnest.id, user_id: @user.username }
    end    
  end

  test "redundant bird creation" do
    log_in_as(@user)
    #don't need to assert this it's tested just above
    post birds_path, bird: { nest_id: @usershipnest.id, user_id: @user.username }
    
    assert_no_difference 'Bird.count'  do
      post birds_path, bird: { nest_id: @usershipnest.id, user_id: @user.username }
    end    
  end

  test "bird deletion" do
    assert_no_difference 'Bird.count' do
      delete bird_path(@singbirdone)
      delete bird_path(@singbirdtwo)
    end
    log_in_as(@other_user)
    assert_no_difference 'Bird.count' do
      delete bird_path(@singbirdone)
      delete bird_path(@singbirdtwo)
    end
    #login as nest owner
    delete logout_path
    log_in_as(@user)
    assert_difference 'Bird.count', -2 do
      delete bird_path(@singbirdone)
      delete bird_path(@singbirdtwo)
    end
  end

  test "test adding birds to another user's nest" do
    #not logged in
    assert_no_difference 'Bird.count' do
      post birds_path, bird: { nest_id: @usershipnest.id, user_id: @user.username }
    end     

    log_in_as(@other_user)
    assert_no_difference 'Bird.count' do
      post birds_path, bird: { nest_id: @usershipnest.id, user_id: @user.username }
    end 
  end

  test "deleting birds from another user's nest" do
    log_in_as(@other_user)
    assert_no_difference 'Bird.count' do
      delete bird_path(@singbirdone)
    end
  end
end