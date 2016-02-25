class Api::V1::UsersController < Api::V1::ApiController
  before_action :set_user, only: [:show, :update]

  skip_before_action :api_authenticate, only: [:login, :create]
  skip_before_action :set_token_header, only: [:login, :create]

  attr_accessor :resource

  # wget --header="Authorization: Token token=scWTF92WXNiH2WhsjueJk4dN" -S http://localhost:3000/api/v1/users/
  def index
    @users = User.all
  end

  def show
  end

  def update
    if @user.update(user_params)
      render :show, status: :ok, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  def destroy
    current_user.update(confirmation_token:    nil,
                        confirmed_at:          nil,
                        confirmation_sent_at:  nil,
                        admin:                 false,
                        api_token:             nil,
                        api_token_valid_until: nil)
    render json: [deleted: true], status: :ok
  end

  # wget --post-data="email=jane@doe.com&password=supersecret" -S http://localhost:3000/api/v1/users/login
  def login
    @user = User.find_by(email: params[:email])
    if @user && @user.confirmed_at.present? && @user.valid_password?(params[:password])
      sign_in(@user)
      @user.regenerate_api_token
      @user.update(api_token_valid_until: Time.now + TOKEN_VALIDITY)
      response.headers['TOKEN'] = @user.api_token
      render json: [logged_in: true], status: :ok
    else
      render json: [logged_in: false], status: :forbidden
    end
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.fetch(:user, {})
    end
end
