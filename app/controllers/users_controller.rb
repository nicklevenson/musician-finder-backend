class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :get_recommended_users, :request_connection]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    connections = @user.connected_users
    render json: @user, methods: [:connected_users, :outgoing_pending_requests]
  end

  def get_recommended_users
    render json: @user.recommended_users
  end

  # POST /users
  def create
    user = User.find_or_create_by(uid: auth['uid'], provider: auth['provider']) do |u|
      u.providerImage = auth['info']['image']
      u.username = auth['info']['name']
      u.email = auth['info']['email']
    end
    if user
      #save image whenever its a login - since they can expire
      user.providerImage = auth['info']['image']
      token = encode_token(user_id: user.id)
      redirect_to('http://localhost:3001/login' + "?token=#{token}" + "?&id=#{user.id}")
    end
  end

  def request_connection
    
    if @user.request_connection(params[:requested_id])
      render json: {message: "Successfully requested"}
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.fetch(:user, {})
    end

    def auth
      request.env['omniauth.auth']
    end 
end
