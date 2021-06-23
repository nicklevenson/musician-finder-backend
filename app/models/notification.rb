class Notification < ApplicationRecord
  belongs_to :user

  default_scope {order(created_at: :desc)}
  after_create :user_email

  def self.make_read(ids)
    ids.each do |id|
      notify = Notification.find(id)
      notify.read = true
      notify.save
    end
  end

  private

    def user_email
      user = self.user
      if user.email_subscribe
        UserMailer.with(user: user, notification: self).notification_email.deliver_later
      end
    end
end
