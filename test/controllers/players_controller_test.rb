require 'test_helper'

class PlayersControllerTest < ActionDispatch::IntegrationTest
  test "should get Index" do
    get players_Index_url
    assert_response :success
  end

end
