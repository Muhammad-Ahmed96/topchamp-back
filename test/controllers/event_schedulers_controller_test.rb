require 'test_helper'

class EventSchedulersControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get event_schedulers_create_url
    assert_response :success
  end

end
