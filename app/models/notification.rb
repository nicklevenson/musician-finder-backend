class Notification < ApplicationRecord
  belongs_to :user

  default_scope {order(created_at: :desc)}


  def self.make_read(ids)
    ids.each do |id|
      notify = Notification.find(id)
      notify.read = true
      notify.save
    end
  end
end
