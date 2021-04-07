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

      connection = Connection.create()
      connection.connection_a_id = @user1.id
      connection.connection_b_id = @user2.id
      connection.save
      
    end
    describe("has association") do
      it "associates connected users" do
        expect(@user1.connected_users.first).to eq(@user2)
      end
    end
  end

end
