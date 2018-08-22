require 'test_helper'

class TournamentMatchesStatusControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get tournament_matches_status_index_url
    assert_response :success
  end

end
