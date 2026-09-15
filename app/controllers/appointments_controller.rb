class AppointmentsController < ApplicationController
  protect_from_forgery with: :null_session
  rescue_from HolidayService::Error, with: :holiday_service_unavailable

  def index
    appointments = Appointment.order(:scheduled_at)

    render json: appointments
  end

  def create
    appointment = Appointment.new(appointment_params)

    if appointment.save
      render json: appointment, status: :created
    else
      render json: { errors: appointment.errors.full_messages },
             status: :unprocessable_content
    end
  end

  def available
    begin
      date = Date.iso8601(params[:date])
    rescue Date::Error, TypeError
      return render json: { error: "Invalid date" }, status: :bad_request
    end
    
    timezone = Time.zone.tzinfo.name

    if date.saturday? || date.sunday?
      return render json: {
        date: date,
        timezone: timezone,
        business_day: false,
        available_slots: []
      }
    end

    if HolidayService.holiday?(date)
      return render json: {
        date: date,
        timezone: timezone,
        business_day: false,
        available_slots: []
      }
    end

    appointments = Appointment.where(scheduled_at: date.all_day)

    occupied_slots = appointments.map do |appointment|
      appointment.scheduled_at.in_time_zone.strftime("%H:%M")
    end

    available_slots = (8...18)
      .map { |hour| format("%02d:00", hour) }
      .reject { |slot| occupied_slots.include?(slot) }

    render json: {
      date: date,
      timezone: timezone,
      business_day: true,
      available_slots: available_slots
    }
  end

  private

  def appointment_params
    params.require(:appointment).permit(:scheduled_at)
  end

  def holiday_service_unavailable
    render json: { error: "Holiday service unavailable" },
          status: :service_unavailable
  end
end