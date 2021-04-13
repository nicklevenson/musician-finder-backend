class User < ApplicationRecord
  has_many :usertags
  has_many :tags, through: :usertags
  has_many :notifications
  has_many :posts
  has_many :messages
  has_many :userchatrooms
  has_many :chatrooms, through: :userchatrooms
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

  validates :username, :email, presence: true

  def connected_users
    connections = Connection.where("connection_a_id = ? OR connection_b_id = ?", self.id, self.id)
    connections.map{|c| c.connection_a_id != self.id ? User.find(c.connection_a_id) : User.find(c.connection_b_id)}
  end

  def request_connection(user_id)
    request = Request.create(requestor_id: self.id, receiver_id: user_id)
    User.find(user_id).notifications << Notification.create(content: "#{self.username} has requested to connect with you")
  end

  def incoming_pending_requests
    self.connection_requests_as_receiver.where("accepted = false").map{|request| User.find(request.requestor_id)}
  end

  def outgoing_pending_requests
    self.connection_requests_as_requestor.where("accepted = false").map{|request| User.find(request.requestor_id)}
  end

  def accept_incoming_connection(requesting_user_id)
    request = Request.find_by(requestor_id: requesting_user_id, receiver_id: self.id)
    request.accepted = true
    requested_user = User.find(requesting_user_id)
    if request.accepted
      Connection.create(connection_a_id: self.id, connection_b_id: requesting_user_id)
      requested_user.notifications << Notification.create(content: "#{self.username} has accepted your connection request")
      chatroom = Chatroom.create()
      chatroom.users << self
      chatroom.users << requested_user
    end
  end

  def reject_incoming_connection(requesting_user_id)
    request = Request.find_by(requestor_id: requesting_user_id, receiver_id: self.id)
    request.destroy
  end

  def recommended_users
    similar_users = User.all.sort_by{|user| (user.tags.map{|tag| tag.name}.intersection(self.tags.map{|tag| tag.name})).length}.reverse()
    filtered_self_and_connections = similar_users.filter{|user| user != self || self.users_not_connected.include?(user)}
    filtered_self_and_connections.map{|u| {user: u, similar_tags: u.tags.map{|tag| tag.name}.intersection(self.tags.map{|tag| tag.name})}}
  end

  def users_not_connected
    User.all.select{|u|!u.connected_users.include?(self) && u != self}
  end
end
