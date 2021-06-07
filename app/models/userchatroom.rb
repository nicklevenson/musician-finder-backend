class Userchatroom < ApplicationRecord
  belongs_to :user 
  belongs_to :chatroom 

  default_scope {order(created_at: :asc)}
end
