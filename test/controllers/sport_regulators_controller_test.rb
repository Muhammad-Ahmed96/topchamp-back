require 'test_helper'

class SportRegulatorsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get sport_regulators_index_url
    assert_response :success
  end

end
