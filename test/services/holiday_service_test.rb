require "test_helper"

class HolidayServiceTest < ActiveSupport::TestCase
  test "returns true when date is a holiday" do
    holidays = [
      {
        "date" => "2026-01-01",
        "localName" => "Confraternização Universal"
      }
    ]

    HolidayService.stub(:holidays, holidays) do
      assert HolidayService.holiday?(Date.new(2026, 1, 1))
    end
  end

  test "returns false when date is not a holiday" do
    holidays = [
      {
        "date" => "2026-01-01",
        "localName" => "Confraternização Universal"
      }
    ]

    HolidayService.stub(:holidays, holidays) do
      assert_not HolidayService.holiday?(Date.new(2026, 2, 10))
    end
  end
end