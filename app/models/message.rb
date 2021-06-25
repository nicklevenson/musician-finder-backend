class Message < ApplicationRecord
  belongs_to :chatroom
  belongs_to :user

  validates :content, presence: true

  after_save :update_chatroom, :message_notification

  private

    def update_chatroom
      chatroom = self.chatroom
      chatroom.updated_at = Time.now
      chatroom.save
    end

    def message_notification
      MessagingNotificationJob.set(wait: 30.minutes).perform_later(self)
    end
end
