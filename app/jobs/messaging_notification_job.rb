class MessagingNotificationJob < ApplicationJob
  queue_as :default

  def perform(*args)
    message = args[0]
    if message.read == false
      sending_user = message.user
      receiving_user = message.chatroom.users.find{|user| user.id != sending_user.id}
      receiving_user.notifications << Notification.create(
                                        content: "recently messaged you. Don't leave them hanging!", 
                                        involved_username: sending_user.username, 
                                        involved_user_id: sending_user.id)
    end
  end
end
