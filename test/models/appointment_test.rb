require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  test "is valid on a weekday during business hours" do
    appointment = Appointment.new(
      scheduled_at: Time.zone.parse("2026-02-10 11:00:00")
    )

    HolidayService.stub(:holiday?, false) do
      assert appointment.valid?
    end
  end

  test "requires scheduled_at" do
    appointment = Appointment.new

    assert_not appointment.valid?
    assert_includes appointment.errors[:scheduled_at], "can't be blank"
  end

  test "does not allow duplicate scheduled_at" do
    scheduled_at = Time.zone.parse("2026-02-10 16:00:00")

    HolidayService.stub(:holiday?, false) do
      Appointment.create!(scheduled_at: scheduled_at)

      duplicate = Appointment.new(scheduled_at: scheduled_at)

      assert_not duplicate.valid?
      assert_includes duplicate.errors[:scheduled_at], "has already been taken"
    end
  end

  test "does not allow appointments outside business hours" do
    appointment = Appointment.new(
      scheduled_at: Time.zone.parse("2026-02-10 20:00:00")
    )

    HolidayService.stub(:holiday?, false) do
      assert_not appointment.valid?
      assert_includes(
        appointment.errors[:scheduled_at],
        "must be between 08:00 and 17:00, on the hour"
      )
    end
  end

  test "does not allow appointments outside full hour slots" do
    appointment = Appointment.new(
      scheduled_at: Time.zone.parse("2026-02-10 13:00:30")
    )

    HolidayService.stub(:holiday?, false) do
      assert_not appointment.valid?
      assert_includes(
        appointment.errors[:scheduled_at],
        "must be between 08:00 and 17:00, on the hour"
      )
    end
  end

  test "does not allow appointments on weekends" do
    appointment = Appointment.new(
      scheduled_at: Time.zone.parse("2026-02-14 10:00:00")
    )

    HolidayService.stub(:holiday?, false) do
      assert_not appointment.valid?
      assert_includes appointment.errors[:scheduled_at], "cannot be on a weekend"
    end
  end

  test "does not allow appointments on holidays" do
    appointment = Appointment.new(
      scheduled_at: Time.zone.parse("2026-01-01 10:00:00")
    )

    HolidayService.stub(:holiday?, true) do
      assert_not appointment.valid?
      assert_includes appointment.errors[:scheduled_at], "cannot be on a holiday"
    end
  end
end
