class Message < ApplicationRecord
  belongs_to :chatroom
  belongs_to :user

  validates :content, presence: true

  after_save :update_chatroom

  private

    def update_chatroom
      chatroom = self.chatroom
      chatroom.updated_at = Time.now
      chatroom.save
    end
end
