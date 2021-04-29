class CreateRejections < ActiveRecord::Migration[6.1]
  def change
    create_table :rejections do |t|
      t.integer :rejector_id
      t.integer :rejected_id
      t.timestamps
    end
  end
end
