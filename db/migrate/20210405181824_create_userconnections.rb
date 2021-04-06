class CreateUserconnections < ActiveRecord::Migration[6.1]
  def change
    create_table :userconnections do |t|
      t.integer :user_id
      t.integer :connection_id
      t.timestamps
    end
  end
end
