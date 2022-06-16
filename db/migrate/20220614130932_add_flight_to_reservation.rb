class AddFlightToReservation < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :flight, :integer
  end
end
