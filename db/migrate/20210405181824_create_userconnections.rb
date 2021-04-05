class CreateUserconnections < ActiveRecord::Migration[6.1]
  def change
    create_table :userconnections do |t|

      t.timestamps
    end
  end
end
