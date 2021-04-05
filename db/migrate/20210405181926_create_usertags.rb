class CreateUsertags < ActiveRecord::Migration[6.1]
  def change
    create_table :usertags do |t|

      t.timestamps
    end
  end
end
