require "net/http"
require "uri"

class HolidayService
  API_URL = "https://date.nager.at/api/v3/PublicHolidays/2026/BR"

  def self.holidays
    uri = URI(API_URL)
    response = Net::HTTP.get_response(uri)

    raise "Holiday API request failed" unless response.is_a?(Net::HTTPSuccess)

    JSON.parse(response.body)
  end

  def self.holiday?(date)
    holidays.any? { |holiday| holiday["date"] == date.to_s }
  end
end