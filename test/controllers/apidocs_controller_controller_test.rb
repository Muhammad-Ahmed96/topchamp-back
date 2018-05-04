require 'test_helper'

class ApidocsControllerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get apidocs_controller_index_url
    assert_response :success
  end

end
