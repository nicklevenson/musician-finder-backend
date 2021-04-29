class UsersController < ApplicationController
  before_action :authorized, except: [:index, :create, :show]
  before_action :set_user, except: [:index, :create]

  # GET /users
  def index
    @users = User.all

    render json: @users, methods: [:connected_users_with_tags, :outgoing_pending_requests]
  end

  # GET /users/1
  def show
    render json: @user, methods: [:connected_users_with_tags, :outgoing_pending_requests], include: [:notifications]
  end

  def get_similar_tags
    render json: @user.similar_tags(params[:other_user_id])[:similar_tags]
  end

  def get_connected_users
    render json: @user.connected_users_with_tags, methods: [:connected_users_with_tags]
  end

  def get_recommended_users
    render json: @user.recommended_users, include: :connected_users_with_tags
  end

  def get_incoming_requests
    render json: @user.incoming_pending_requests, methods: [:connected_users_with_tags]
  end

  # POST /users
  def create
 
    user = User.find_or_create_by(uid: auth['uid'], provider: auth['provider']) do |u|
      u.providerImage = auth['info']['image']
      u.username = auth['info']['name']
      u.email = auth['info']['email']
      if auth['credentials']['token']
        u.token = auth['credentials']['token']
        u.refresh_token = auth['credentials']['refresh_token']
        u.fetch_spotify_data
      end
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

  def accept_connection
    if @user.accept_incoming_connection(params[:requesting_user_id])
      render json: {message: "Successfully accepted"}
    end
  end

  def reject_connection
    if @user.reject_incoming_connection(params[:requesting_user_id])
      render json: {message: "Successfully rejected"}
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
