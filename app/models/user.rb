class User < ApplicationRecord
  validates :username, :email, :location, presence: true
end
