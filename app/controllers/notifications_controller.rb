class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :update, :destroy]

  def make_read
    Notification.make_read(params[:ids])
  end
  

end
