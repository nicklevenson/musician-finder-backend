class CreateUsergenres < ActiveRecord::Migration[6.1]
  def change
    create_table :usergenres do |t|
      t.integer :user_id
      t.integer :genre_id
      t.timestamps
    end
  end
end
