class Connection < ApplicationRecord
  belongs_to :connection_a, class_name: :User
  belongs_to :connection_b, class_name: :User
end
