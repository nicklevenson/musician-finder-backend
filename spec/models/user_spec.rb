require 'rails_helper'

RSpec.describe User, type: :model do

  before do
    @user1 = User.create(username: "hello", email: "hello.com", location: "LA")
    @user2 = User.create(username: "hello2", email: "hello.com2", location: "LA2")
    @user3 = User.create(username: "hello3", email: "hello.com3", location: "LA3")
  end
  describe 'validations' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:location) }
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
        @user1.tags.build(name: "rock")
        @user1.tags.build(name: "country")
        @user1.tags.build(name: "blues")
        @user1.save

        @user2.tags.build(name: "rock")
        @user2.tags.build(name: "country")
        @user2.tags.build(name: "disco")
        @user2.save
        
        @user3.tags.build(name: "house")
        @user3.tags.build(name: "rap")
        @user3.tags.build(name: "disco")
        @user3.save
      end
      it "gives a list of reccomended users based on similar tags" do
        print @user1.recommended_users
      end
    end
  end

end
