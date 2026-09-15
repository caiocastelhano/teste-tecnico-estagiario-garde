require "net/http"
require "uri"

class HolidayService
  class Error < StandardError; end

  API_URL = "https://date.nager.at/api/v3/PublicHolidays/2026/BR"

  def self.holidays
    uri = URI(API_URL)
    response = Net::HTTP.get_response(uri)

    unless response.is_a?(Net::HTTPSuccess)
      raise Error, "Holiday API request failed"
    end

    JSON.parse(response.body)
  rescue SocketError, Timeout::Error, JSON::ParserError => e
    raise Error, e.message
  end

  def self.holiday?(date)
    holidays.any? { |holiday| holiday["date"] == date.to_s }
  end
end