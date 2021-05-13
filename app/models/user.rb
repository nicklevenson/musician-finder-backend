class User < ApplicationRecord
  has_many :usertags, dependent: :destroy
  has_many :tags, through: :usertags
  has_many :userinstruments, dependent: :destroy
  has_many :instruments, through: :userinstruments
  has_many :usergenres, dependent: :destroy
  has_many :genres, through: :usergenres
  has_many :notifications, dependent: :destroy
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
  has_many :a_connected_users, foreign_key: :connection_a_id, class_name: :Connection
  has_many :b_connected_users, foreign_key: :connection_b_id, class_name: :Connection

  has_many :rejections, foreign_key: :rejector_id, class_name: :Rejection

  validates :username, :email, presence: true

  after_create :new_user_notification


  def recommended_users(parameters)
    range = parameters["mileRange"] && parameters["mileRange"] < 500 ? parameters["mileRange"] : nil
    instruments = parameters["instruments"] || nil
    genres = parameters["genres"] || nil
      
    similar_users = similarly_tagged_users(range: range, instruments: instruments, genres: genres)

  end

  #connection methods
  def connected_users
    connections = Connection.where("connection_a_id = ? OR connection_b_id = ?", self.id, self.id)
    User.where(id: connections.map{|c| c.connection_a_id != self.id ? c.connection_a_id : c.connection_b_id})
  end

  def connected_users_with_tags
    connections = Connection.where("connection_a_id = ? OR connection_b_id = ?", self.id, self.id)
    connections.map{|c| c.connection_a_id != self.id ? similar_tags(c.connection_a_id) : similar_tags(c.connection_b_id)}
  end

  def users_not_connected
    User.where.not(id: self.id).where.not(id: self.connected_users.select(:id))
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
    User.where(id: self.connection_requests_as_receiver.where("accepted = false").map{|request|request.requestor_id})
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

  def similar_tags(user_id)
    other_user = User.find(user_id)
    other_user.tags.includes(:users).where(:users => {id: self.id})
  end

  def rejected_users
    User.where(id: self.rejections.map{|r| r.rejected_id})
  end
  
  def reject_user(user_id)
    self.rejections.build(rejected_id: user_id, rejector_id: self.id)
    self.save
  end

  # geolocation methods
  def user_distance(other_user)
    if self.lat && self.lng && other_user.lat && other_user.lng
      lat1 = other_user.lat
      lng1 = other_user.lng
      lat2 = self.lat
      lng2 = self.lng
      Geocoding.get_distance_between(lat1, lng1, lat2, lng2)
    else
      500
    end
  end

  def is_in_range(other_user, range)
    #range in miles
    if user_distance(other_user) <= range
      true
    else
      false
    end
  end

  def users_in_range(users, range)
    users.select do |user|
      if user_distance(user) <= range
        true
      else
        false
      end
    end
    .map{|user|user.id}
  end

  #spotify methods

  def fetch_spotify_data
    if self.provider === 'spotify'
      refresh_spotify_token
      header = {
        Authorization: "Bearer #{self.token}"
      }
      resp = RestClient.get("https://api.spotify.com/v1/me/top/artists", header)
      items = JSON.parse(resp)['items']
      if items[0]
        remove_old_spotify_tags
        items.each do |i|
          name = i["name"]
          tag = Tag.find_or_create_by(name: name)
          tag.tag_type = "spotify_artist"
          tag.image_url = i["images"][0]["url"]
          tag.link = i["href"]
          tag.uri = i["uri"]
          tag.save
          self.tags << tag
        end
      end
    end
  end

  def remove_old_spotify_tags
    tags = self.tags.where(tag_type: "spotify_artist")
    tags.each do |t|
      self.tags.delete(t)
    end
  end

  def spotify_token_expired
    (Time.now - self.updated_at) > 3300
  end

  def refresh_spotify_token
    if spotify_token_expired
      body = {
        grant_type: "refresh_token",
        refresh_token: self.refresh_token,
        client_id: Rails.application.credentials.spotify[:client_id],
        client_secret: Rails.application.credentials.spotify[:client_secret]
      }

      resp = RestClient.post('https://accounts.spotify.com/api/token', body)
      json = JSON.parse(resp)
      self.token = json["access_token"]
    end
  end


  # nested helpers
  def tags_attributes=(tags_attributes)
    self.tags.delete_all
    tags_attributes.each do |tag_attribute|
      tag = Tag.find_or_create_by(name: tag_attribute["name"])
      self.tags << tag unless self.tags.include?(tag)
    end
  end
  def genres_attributes=(genres_attributes)
    self.genres.delete_all
    genres_attributes.each do |genre_attribute|
      genre = Genre.find_or_create_by(name: genre_attribute["name"])
      self.genres << genre unless self.genres.include?(genre)
    end
  end
  def instruments_attributes=(instruments_attributes)
    self.instruments.delete_all
    instruments_attributes.each do |instrument_attribute|
      instrument = Instrument.find_or_create_by(name: instrument_attribute["name"])
      self.instruments << instrument unless self.instruments.include?(instrument)
    end
  end


  def similarly_tagged_users(range: nil, instruments: nil, genres: nil)
    conn = ActiveRecord::Base

    no_ids = self.connected_users.map{|user|user.id}.push(self.id)

    instrument_user_ids = instruments ? Userinstrument.where(instrument_id: Instrument.where(name: instruments)).pluck(:user_id) : nil
    instrument_query = instrument_user_ids ? conn.sanitize_sql_array(["u.id IN(?)", instrument_user_ids]) : "true"

    range_query = range ? conn.sanitize_sql_array(["u.id IN(?)", self.users_in_range(User.all, range)]) : "true"

    genre_user_ids = genres ? Usergenre.where(genre_id: Genre.where(name: genres)).pluck(:user_id) : nil
    genre_query = genre_user_ids ? conn.sanitize_sql_array(["u.id IN(?)", genre_user_ids]) : "true"

    sql2 = <<~SQL
      SELECT u.id, COALESCE(matching_tag_counts.n, 0) AS similarity_score
      FROM users AS u
        LEFT OUTER JOIN (
          SELECT user_id, COUNT(*) AS n
          FROM usertags
          WHERE #{conn.sanitize_sql_array(["tag_id IN(?)", self.tag_ids])}
          GROUP BY user_id
        ) AS matching_tag_counts ON u.id=matching_tag_counts.user_id
        WHERE #{conn.sanitize_sql_array(["u.id NOT IN(?)", no_ids])}
        AND #{range_query}
        AND #{instrument_query}
        AND #{genre_query}
        ORDER BY similarity_score DESC
        LIMIT 50
    SQL
    sanatized = ActiveRecord::Base::sanitize_sql(sql2)
    self.class.where(id: User.find_by_sql(sanatized))
  end

  private

    def new_user_notification
      self.notifications << Notification.create(content: "Thanks for joining Matchup Music! We're excited to have you.")
    end

    def set_coords
      if self.location
        coords = Geocoding.find_coords_with_city(self.location)
        self.lat = coords[0]
        self.lng = coords[1]
      end
    end


end
