class Usergenre < ApplicationRecord
  belongs_to :user
  belongs_to :genre

  default_scope {order(created_at: :asc)}
end
