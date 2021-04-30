class Genre < ApplicationRecord
  has_many :usergenres
  has_many :users, through: :usergenres
end
