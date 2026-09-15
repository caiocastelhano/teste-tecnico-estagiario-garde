class AddUniqueIndexToAppointmentsScheduledAt < ActiveRecord::Migration[7.1]
  def change
    add_index :appointments, :scheduled_at, unique: true
  end
end
