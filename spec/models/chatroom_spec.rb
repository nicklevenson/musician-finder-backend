require 'rails_helper'

RSpec.describe Chatroom, type: :model do
  describe "associations" do
    it { should have_many(:users).class_name('User') }
    it { should have_many(:messages).class_name('Message') }
  end
end
