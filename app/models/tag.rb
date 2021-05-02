class Tag < ApplicationRecord
  has_many :usertags, dependent: :destroy
  has_many :users, through: :usertags
  
end
