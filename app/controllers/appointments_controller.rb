class AppointmentsController < ApplicationController
  protect_from_forgery with: :null_session

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
             status: :unprocessable_entity
    end
  end

  def available
    date = Date.iso8601(params[:date])

    if date.saturday? || date.sunday?
      return render json: { date: date, available_slots: [] }
    end

    if HolidayService.holiday?(date)
      return render json: { date: date, available_slots: [] }
    end

    appointments = Appointment.where(scheduled_at: date.all_day)

    occupied_slots = appointments.map { |appointment| appointment.scheduled_at.in_time_zone.strftime("%H:%M") }

    available_slots = (8...18)
      .map { |hour| format("%02d:00", hour) }
      .reject { |slot| occupied_slots.include?(slot) }

    render json: { date: date, available_slots: available_slots }
  end

  private

  def appointment_params
    params.require(:appointment).permit(:scheduled_at)
  end
end