class Usertag < ApplicationRecord
  belongs_to :user
  belongs_to :tag

   default_scope {order(created_at: :asc)}
end
