require 'test_helper'

class EventRegistrationRulesControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get event_registration_rules_create_url
    assert_response :success
  end

end
