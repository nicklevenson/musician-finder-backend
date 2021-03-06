require 'rails_helper'
require 'byebug'
RSpec.describe User, type: :model do

  before do
    @user1 = User.create(username: "hello", email: "hello.com", location: "Ashland, OR")
    @user2 = User.create(username: "hello2", email: "hello.com2", location: "Portland, OR")
    @user3 = User.create(username: "hello3", email: "hello.com3", location: "Seattle, WA")
    @user1.set_coords
    @user2.set_coords
    @user3.set_coords
  end
  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
   
  end

  describe 'associations' do
    it { should have_many(:notifications).class_name('Notification') }
    it { should have_many(:tags).class_name('Tag') }
    it { should have_many(:connection_requests_as_requestor) }
    it { should have_many(:connection_requests_as_receiver) }
   
  end

  describe "has many connected users" do
    before do
     
      connection = Connection.create(connection_a_id: @user1.id, connection_b_id: @user2.id)

      connection = Connection.create()
      connection.connection_a_id = @user1.id
      connection.connection_b_id = @user3.id
      connection.save
      
    end
    describe("has association") do
      it "associates connected users" do
        expect(@user1.connected_users.first).to eq(@user2)
        expect(@user2.connected_users.first).to eq(@user1)
        expect(@user1.connected_users.second).to eq(@user3)
        expect(@user3.connected_users.first).to eq(@user1)
        # print @user3.connected_users
      end
    end
  end

  describe "connection requests" do
    before do
      @user1.request_connection(@user2.id)
      @user2.request_connection(@user3.id)
    end

    describe("User can request a connection") do
      it "can request a user to connect" do
        expect(@user2.connection_requests_as_receiver.first.requestor_id)
      end
    end

    describe("Can see incoming pending requests") do
      it "shows all pending incoming requests" do
        expect(@user3.incoming_pending_requests.first).to eq(@user2)
        expect(@user2.incoming_pending_requests.first).to eq(@user1)
      end
    end

    describe("Accept Request Connection") do
      before do
        @user2.accept_incoming_connection(@user2.incoming_pending_requests.first.id)
      end
      it "accepts an incoming request and creates a new conneciton" do
        expect(@user2.connected_users.first).to eq(@user1)
        expect(@user1.connected_users.first).to eq(@user2)
      end
      it "creates a new chatroom" do
        expect(@user1.chatrooms.first.users).to eq([@user1, @user2])
      end
    end

    describe("Reject Connection Request") do
      before do
        @user2.reject_incoming_connection(@user2.incoming_pending_requests.first.id)
      end
      it "destroys an incoming request" do
        expect(@user2.incoming_pending_requests).to be_empty
        expect(@user1.outgoing_pending_requests).to be_empty
      end
    end

  end

  describe("Listing user relations") do
    describe("Users not connected") do
      it "gives a list of users who are not connected" do
       
        expect(@user1.users_not_connected).to include(@user2, @user3)
      end
    end

    describe("recommended users") do
      before do
        @tag1 = Tag.create(name: "rock")
        @tag2 = Tag.create(name: "country")
        @tag3 = Tag.create(name: "blues")
        @tag4 = Tag.create(name: "house")
        @tag5 = Tag.create(name: "disco")

        @tag1.users << [@user1, @user2]
        @tag2.users << [@user1, @user2]
        @tag3.users << [@user1]
        @tag4.users << [@user3]
        @tag5.users << [@user2, @user3]


        @genre = Genre.create(name: "Rock")
        @instrument = Instrument.create(name: "Guitar")
        @genre.users << [@user1, @user2]
        @instrument.users << @user3

        Tag.all.each{|tag|tag.save}
        User.all.each{|user|user.save}

      end
      it "gives a list of recommended users based on similar tags" do
        expect(@user1.recommended_users({}).first).to eq(@user2)
        expect(@user1.recommended_users({}).last).to eq(@user3)
        expect(@user2.recommended_users({}).first).to eq(@user1)
        expect(@user2.recommended_users({}).last).to eq(@user3)
        expect(@user3.recommended_users({}).first).to eq(@user2)
        
        expect(@user3.similar_tags(@user1.id)).to eq([])
        expect(@user3.similar_tags(@user2.id).first).to eq(@tag5)
      end

      it "gives list based on filter parameters" do 
        expect(@user1.similarly_tagged_users(instruments: ["Guitar"])).to eq([@user3])
        expect(@user1.similarly_tagged_users(genres: ["Rock", "Blues"])).to eq([@user2])
        expect(@user1.similarly_tagged_users(range: 400)).to eq([@user2, @user3])
        expect(@user1.similarly_tagged_users(range: 400, genres:["Rock"])).to eq([@user2])
        expect(@user1.similarly_tagged_users(range: 400, genres:["Rock"], instruments: ["Guitar"])).to eq([@user2, @user3])
      end
    end

    describe "notifications" do
      before do
        @user1.request_connection(@user2.id)
        @user1.request_connection(@user3.id)
        @user3.accept_incoming_connection(@user1.id)
      end
      it "creates a new notification for the user that is being requested" do
        expect(@user2.notifications.length).to eq(2)
      end
      it "creates a new notification for the requesting user when the request was accepted" do
        expect(@user3.notifications.length).to eq(2)
        expect(@user1.notifications.length).to eq(2)
      end 
    end
  end

  describe "geolocation" do
    it "can return a list of user ids in a mile radius" do
      expect(@user2.users_in_range([@user1, @user3], 200)).to eq([@user3.id])
      expect(@user2.users_in_range([@user1, @user3], 400)).to eq([@user1.id, @user3.id])
      expect(@user3.users_in_range([@user1, @user2], 146)).to eq([@user2.id])
    end
  end

end
