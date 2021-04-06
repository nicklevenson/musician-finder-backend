class User < ApplicationRecord
  has_many :usertags
  has_many :tags, through: :usertags
  has_many :notifications
  has_many :userconnections
  has_many :connections, through: :userconnections
  has_many :posts
  has_many :requests


  validates :username, :email, :location, presence: true
end
