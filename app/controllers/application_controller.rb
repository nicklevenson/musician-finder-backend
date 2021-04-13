class ApplicationController < ActionController::API
  def encode_token(user_id)
    JWT.encode(user_id, Rails.application.credentials.jwt[:secret])
  end

  def decode_token(token)
    JWT.decode(token, Rails.application.credentials.jwt[:secret])[0]
  end

  def auth_header
    request.headers['Authorization']
  end

  def decoded_token
    if auth_header
      token = auth_header.split(' ')[1]
      begin
        JWT.decode(token, Rails.application.credentials.jwt[:secret], true, algorithm: 'HS256')
      rescue JWT::DecodeError
        nil
      end
    end
  end
  
  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      user = User.find_by(id: user_id)
    end
  end

  def logged_in?
    !!current_user
  end

  def authorized
    render json: {message: "Please Login", status: :unauthorized} unless logged_in?
  end
  
  def authenticate
    redirect_to '/auth/google_oauth2'
  end
end
