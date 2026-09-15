require "test_helper"

class AppointmentsControllerTest < ActionDispatch::IntegrationTest
  test "lists appointments" do
    get appointments_path

    assert_response :success

    data = JSON.parse(response.body)

    assert_kind_of Array, data
  end

  test "returns available slots for a business day" do
    scheduled_at = Time.zone.parse("2026-02-10 11:00:00")

    HolidayService.stub(:holiday?, false) do
      Appointment.create!(scheduled_at: scheduled_at)

      get available_path, params: { date: "2026-02-10" }
    end

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal "2026-02-10", data["date"]
    assert_equal "America/Sao_Paulo", data["timezone"]
    assert_equal true, data["business_day"]

    assert_includes data["available_slots"], "08:00"
    assert_not_includes data["available_slots"], "11:00"
  end

  test "returns no available slots on weekends" do
    get available_path, params: { date: "2026-02-14" }

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal false, data["business_day"]
    assert_empty data["available_slots"]
  end

  test "returns no available slots on holidays" do
    HolidayService.stub(:holiday?, true) do
      get available_path, params: { date: "2026-01-01" }
    end

    assert_response :success

    data = JSON.parse(response.body)

    assert_equal false, data["business_day"]
    assert_empty data["available_slots"]
  end

  test "returns bad request for invalid date" do
    get available_path, params: { date: "banana" }

    assert_response :bad_request

    data = JSON.parse(response.body)

    assert_equal "Invalid date", data["error"]
  end

  test "creates an appointment" do
    HolidayService.stub(:holiday?, false) do
      assert_difference("Appointment.count", 1) do
        post appointments_path,
             params: {
               appointment: {
                 scheduled_at: "2026-02-10T13:00:00-03:00"
               }
             },
             as: :json
      end
    end

    assert_response :created

    data = JSON.parse(response.body)

    assert_equal 13, Time.zone.parse(data["scheduled_at"]).hour
  end

  test "does not create duplicate appointment" do
    scheduled_at = Time.zone.parse("2026-02-10 16:00:00")

    HolidayService.stub(:holiday?, false) do
      Appointment.create!(scheduled_at: scheduled_at)

      assert_no_difference("Appointment.count") do
        post appointments_path,
             params: {
               appointment: {
                 scheduled_at: scheduled_at.iso8601
               }
             },
             as: :json
      end
    end

    assert_response :unprocessable_content

    data = JSON.parse(response.body)

    assert data["errors"].any?
  end
end
