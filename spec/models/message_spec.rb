require 'rails_helper'

RSpec.describe Message, type: :model do
  describe "associations" do
    it { should belong_to(:user).class_name('User') }
    it { should belong_to(:chatroom).class_name('Chatroom') }
  end

  describe "validations" do
    it { should validate_presence_of(:content)}
  end
end
