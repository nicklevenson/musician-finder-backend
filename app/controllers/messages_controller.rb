class MessagesController < ApplicationController
  before_action :authorized
  def create
    message = Message.new(message_params)
    if message.save
      render json: message
    end
  end

  def make_read
    chatroom = Chatroom.find(params[:chatroom_id])
    messages_to_make_read = chatroom.messages.select{|m| m.user_id != current_user.id}
    messages_to_make_read.each do |mes|
      mes.read = true
      mes.save
    end
    if chatroom.save
      render json: chatroom
    end

  end
  private

    def message_params
      params.require(:message).permit(:content, :chatroom_id, :user_id)
    end
end
