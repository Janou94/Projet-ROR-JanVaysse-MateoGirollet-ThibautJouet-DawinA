class CreateReservations < ActiveRecord::Migration[7.0]
  def change
    create_table :reservations do |t|
      t.text :reference
      t.string :user
      t.integer :flight_nb
      t.boolean :is_business

      t.timestamps
    end
  end
end
