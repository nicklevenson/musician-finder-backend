class Chatroom < ApplicationRecord
  has_many :messages
  has_many :userchatrooms
  has_many :users, through: :userchatrooms

 
end
