require 'test_helper'

class ProcessingFeesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get processing_fees_index_url
    assert_response :success
  end

end
