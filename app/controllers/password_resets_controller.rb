class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "We’ve sent you an email with password reset instructions."
      redirect_to root_url
    else
      flash.now[:danger] = "We can’t find that email address. " +
                           "Please make sure it’s the address you signed up with."
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      flash.now[:danger] = "Your password can’t be empty."
      render 'edit'
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Your password has been updated."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private
    # Strong parameters
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Before filters

    # Get user by email.
    def get_user
      @user = User.find_by(email: params[:email])
    end
   
    # Confirms a valid user.
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end        

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Your password reset link has expired."
        redirect_to new_password_reset_url
      end
    end
end
