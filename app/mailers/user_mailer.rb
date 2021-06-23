class UserMailer < ApplicationMailer

  def notification_email
    @user = params[:user]
    @notification = params[:notification]
    mail(to: @user.email, subject: "New Notification")
  end
end
