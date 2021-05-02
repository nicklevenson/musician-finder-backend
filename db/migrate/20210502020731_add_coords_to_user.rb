class AddCoordsToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :lng, :decimal, precision: 10, scale: 6
    add_column :users, :lat, :decimal, precision: 10, scale: 6
  end
end
