class UsersController < ApplicationController
  before_action :authorized, except: [:index, :create, :show]
  before_action :set_user, except: [:index, :create]

  # GET /users
  def index
    @users = User.all

    render json: MultiJson.dump(@users, except: [:token, :refresh_token], methods: [:connected_users_with_tags, :outgoing_pending_requests])
  end

  # GET /users/1
  def show
    render json: MultiJson.dump(@user, except: [:token, :refresh_token], 
      methods: [:connected_users, :outgoing_pending_requests], 
      include: [:tags => {except: [:created_at, :updated_at]}, :genres => {only: :name}, :instruments => {only: :name}])
  end

  def get_similar_tags
    render json: MultiJson.dump(@user.similar_tags(params[:other_user_id]))
  end

  def get_connected_users
    render json: MultiJson.dump(@user.connected_users, include: :tags)
  end

  def get_recommended_users
    recommendations = @user.recommended_users(recommended_users_params)
    
    if recommendations
      render json: MultiJson.dump(recommendations)
    end
  end

  def get_incoming_requests
    render json: MultiJson.dump(@user.incoming_pending_requests)
  end

  def get_user_chatrooms
    @user = User.includes(:chatrooms => [{:userchatrooms => :user}, :users, {:messages => :user}]).find(params[:id])
    render json: MultiJson.dump(@user.chatrooms, include: [:users, :messages => {
      include: [:user => {only: [:username, :id, :location, :photo, :providerImage]}]
      }])
  end

  def get_user_notifications
    render json: MultiJson.dump(@user.notifications)
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
      end
    end
    if user
      #save image whenever its a login - since they can expire
      user.providerImage = auth['info']['image']
      user.fetch_spotify_data
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

  def reject_user
    if @user.reject_user(params[:rejected_id])
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
      params.require(:user).permit(:bio, :location, tags_attributes: [:name, :tag_type, :spotify_uri, :spotify_image_url, :spotify_link], genres_attributes: [:name], instruments_attributes: [:name])
    end

    def recommended_users_params
      params.require(:filterParamsObject).permit(:noFilter, :mileRange, {:instruments => []}, :genres)
    end

    def auth
      request.env['omniauth.auth']
    end 
end
