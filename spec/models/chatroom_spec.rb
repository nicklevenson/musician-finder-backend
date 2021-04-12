require 'rails_helper'

RSpec.describe Chatroom, type: :model do
  describe "associations" do
    it { should have_many(:users).class_name('User') }
    it { should have_many(:messages).class_name('Message') }
  end

  describe "finds chatroom and messages" do
    before do
      @user1 = User.create(username: "hello", email: "hello.com", location: "LA")
      @user2 = User.create(username: "hello2", email: "hello.com2", location: "LA2")
      @chatroom = Chatroom.create()
      @chatroom.users << @user1
      @chatroom.users << @user2
      @user1.messages.build(content: "WOO", chatroom_id: @chatroom.id).save
      Chatroom.create()
      Chatroom.create()
      
    end

    it "finds a chatroom based on two user ids" do
      expect(@user1.chatrooms).to eq([@chatroom])
      expect(@user1.chatrooms.first).to eq(@chatroom)
      expect(@user2.chatrooms.first).to eq(@chatroom)
      expect(@chatroom.messages.first.content).to eq("WOO")
      expect(@chatroom.messages.first.user).to eq(@user1)
    end
  end
end
