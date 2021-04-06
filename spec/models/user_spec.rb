require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'create user' do
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:location) }
  end
end
