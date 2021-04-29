class Rejection < ApplicationRecord
  belongs_to :rejector, class_name: :User
  belongs_to :rejected, class_name: :User
end
