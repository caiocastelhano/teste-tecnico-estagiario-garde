class Appointment < ApplicationRecord
  validates :scheduled_at, presence: true, uniqueness: true
  validate :within_business_hours
  validate :not_on_weekend
  validate :not_on_holiday

  private

  def within_business_hours
    return if scheduled_at.blank?

    local_time = scheduled_at.in_time_zone

    unless (8...18).cover?(local_time.hour) && local_time.min.zero?
      errors.add(:scheduled_at, "must be between 08:00 and 17:00, on the hour")
    end
  end

  def not_on_weekend
    return if scheduled_at.blank?

    local_date = scheduled_at.in_time_zone.to_date

    if local_date.saturday? || local_date.sunday?
      errors.add(:scheduled_at, "cannot be on a weekend")
    end
  end

  def not_on_holiday
    return if scheduled_at.blank?

    local_date = scheduled_at.in_time_zone.to_date

    if HolidayService.holiday?(local_date)
      errors.add(:scheduled_at, "cannot be on a holiday")
    end
  end
end
