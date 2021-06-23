class AddSubscribeToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :email_subscribe, :boolean, default: true
  end
end
