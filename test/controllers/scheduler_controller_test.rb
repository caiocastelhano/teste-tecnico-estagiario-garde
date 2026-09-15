require "test_helper"

class SchedulerControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url

    assert_response :success
  end
end
