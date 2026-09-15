class CreateAppointments < ActiveRecord::Migration[7.1]
  def change
    create_table :appointments do |t|
      t.datetime :scheduled_at, null: false

      t.timestamps
    end
  end
end
