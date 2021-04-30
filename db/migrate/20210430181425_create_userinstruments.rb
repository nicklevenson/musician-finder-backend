class CreateUserinstruments < ActiveRecord::Migration[6.1]
  def change
    create_table :userinstruments do |t|
      t.integer :user_id
      t.integer :instrument_id
      t.timestamps
    end
  end
end
