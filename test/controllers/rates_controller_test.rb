require 'test_helper'

class RatesControllerTest < ActionController::TestCase
  def setup
    @rating = ratings(:one)
    @activity = activities(:orange)
    @rate = rates(:one)
  end

  test "should redirect create when not logged in" do
    assert_no_difference 'Rating.count' do
      post :create, rate: { rating_id: @rating.id }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do
    assert_no_difference 'Rating.count' do
      delete :destroy, id: @rating
    end
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    assert_no_difference 'Rating.count' do
      patch :update, id: @rate
    end
    assert_redirected_to login_url
  end
end
