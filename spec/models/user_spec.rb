require 'rails_helper'

RSpec.describe User, type: :model do
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
      @user1 = User.create(username: "hello", email: "hello.com", location: "LA")
      @user2 = User.create(username: "hello2", email: "hello.com2", location: "LA2")
      @user3 = User.create(username: "hello3", email: "hello.com3", location: "LA3")
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
      @user1 = User.create(username: "hello", email: "hello.com", location: "LA")
      @user2 = User.create(username: "hello2", email: "hello.com2", location: "LA2")
      @user3 = User.create(username: "hello3", email: "hello.com3", location: "LA3")
      @user1.request_connection(@user2.id)
      @user2.request_connection(@user3.id)
    end

    describe("User can request a connection") do
      it "can request a user to connect" do
        # print @user1.connection_requests_as_requestor
        # print @user2.connection_requests_as_receiver.first.requestor_id
        # print @user3.connection_requests_as_receiver
      end
    end

    describe("Can see incoming pending requests") do
      it "shows all pending incoming requests" do
        print @user3.incoming_pending_requests
      end
    end

  end

end
