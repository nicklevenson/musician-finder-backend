class Connection < ApplicationRecord
  has_many :userconnections

  has_many :users, through: :userconnections
end
