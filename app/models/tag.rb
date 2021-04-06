class Tag < ApplicationRecord
  has_many :usertags
  has_many :users, through: :usertags
  
end
