class User < ApplicationRecord
  has_many :usertags
  has_many :tags, through: :usertags
  has_many :notifications
  has_many :posts
  
  has_many :connection_requests_as_requestor,
    foreign_key: :requestor_id,
    class_name: :Request
  
  has_many :connection_requests_as_receiver, 
    foreign_key: :receiver_id, 
    class_name: :Request

  has_many :connections
  # , ->(user) { where("connection_a_id = ? OR connection_b_id = ?", user.id, user.id) }
  has_many :a_connected_users, foreign_key: :connection_a_id, class_name: :Connection
  has_many :b_connected_users, foreign_key: :connection_b_id, class_name: :Connection

  validates :username, :email, :location, presence: true

  def connected_users
    a_connected_users + b_connected_users
  end
end
