class CreateUsertags < ActiveRecord::Migration[6.1]
  def change
    create_table :usertags do |t|
      t.integer :user_id
      t.integer :tag_id
      t.timestamps
    end
  end
end
