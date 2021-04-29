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

  has_many :rejections, foreign_key: :rejector_id, class_name: :Rejection
  

  validates :username, :email, presence: true


  def connected_users
    connections = Connection.where("connection_a_id = ? OR connection_b_id = ?", self.id, self.id)
    connections.map{|c| c.connection_a_id != self.id ? User.find(c.connection_a_id) : User.find(c.connection_b_id)}
  end

  def connected_users_with_tags
    connections = Connection.where("connection_a_id = ? OR connection_b_id = ?", self.id, self.id)
    connections.map{|c| c.connection_a_id != self.id ? similar_tags(c.connection_a_id) : similar_tags(c.connection_b_id)}
  end
  def request_connection(user_id)
    if !(connected_users.include?(User.find(user_id)))
      request = Request.find_or_create_by(requestor_id: self.id, receiver_id: user_id)
      User.find(user_id).notifications << Notification.create(content: "has requested to connect with you", involved_username: self.username , involved_user_id: self.id)
      if request.save
        true
      else
        false
      end
    else
      "Already Connected"
    end

  
  end

  def incoming_pending_requests
    self.connection_requests_as_receiver.where("accepted = false").map{|request| similar_tags(request.requestor_id)}
  end

  def outgoing_pending_requests
    self.connection_requests_as_requestor.where("accepted = false").map{|request| User.find(request.receiver_id)}
  end

  def accept_incoming_connection(requesting_user_id)
    request = Request.find_by(requestor_id: requesting_user_id, receiver_id: self.id)
    requested_user = User.find(requesting_user_id)
    if request
      Connection.find_or_create_by(connection_a_id: self.id, connection_b_id: requesting_user_id)
      requested_user.notifications << Notification.create(content: "has accepted your connection request", involved_username: self.username , involved_user_id: self.id)
      chatroom = Chatroom.create()
      chatroom.users << self
      chatroom.users << requested_user
      request.destroy
    end
  end

  def reject_incoming_connection(requesting_user_id)
    request = Request.find_by(requestor_id: requesting_user_id, receiver_id: self.id)
    request.destroy
  end

  def recommended_users
    similar_users = User.all.sort_by{|user| (user.tags.map{|tag| tag.name}.intersection(self.tags.map{|tag| tag.name})).length}.reverse()[0..50]
    filtered_self_and_connections = similar_users.filter{|user| users_not_connected.include?(user)}.filter{|user| !self.rejected_users.include?(user)}
    filtered_self_and_connections.map{|u| u.similar_tags(u.id)}
  end

  def users_not_connected
    User.all.select{|u|self.connected_users.exclude?(u) === true && u != self}
  end

  def similar_tags(user_id)
    other_user = User.find(user_id)
    {user: other_user, similar_tags: other_user.tags.map{|tag| tag.name}.intersection(self.tags.map{|tag| tag.name})}
  end


  def rejected_users
    User.where(id: self.rejections.map{|r| r.rejected_id})
  end
  
  def reject_user(user_id)
    self.rejections.build(rejected_id: user_id, rejector_id: self.id)
    self.save
  end
end
