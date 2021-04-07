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
    connections = Connection.where("connection_a_id = ? OR connection_b_id = ?", self.id, self.id)
    connections.map{|c| c.connection_a_id != self.id ? User.find(c.connection_a_id) : User.find(c.connection_b_id)}
  end

  def request_connection(user_id)
    request = Request.create(requestor_id: self.id, receiver_id: user_id)
  end

  def incoming_pending_requests
    self.connection_requests_as_receiver.where("accepted = false").map{|request| User.find(request.requestor_id)}
  end
end
