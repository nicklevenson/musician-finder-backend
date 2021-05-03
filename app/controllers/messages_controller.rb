class MessagesController < ApplicationController
  before_action :authorized
  def create
    message = Message.new(message_params)
    if message.save
      render json: message
    end
  end

  def make_read
    message = Message.find(params[:message_id])
    message.read = true
    if message.save
      render json: message
    end
  end
  private

    def message_params
      params.require(:message).permit(:content, :chatroom_id, :user_id)
    end
end
