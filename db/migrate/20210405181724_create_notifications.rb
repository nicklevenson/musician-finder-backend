class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.string :content
      t.boolean :read, default: false
      t.integer :involved_user_id
      t.string :involved_username
      t.timestamps
    end
  end
end
