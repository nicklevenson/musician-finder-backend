class Instrument < ApplicationRecord
  has_many :userinstruments
  has_many :users, through: :userinstruments
end

