class CreateUserchatrooms < ActiveRecord::Migration[6.1]
  def change
    create_table :userchatrooms do |t|
      t.integer :chatroom_id
      t.integer :user_id
      t.timestamps
    end
  end
end
