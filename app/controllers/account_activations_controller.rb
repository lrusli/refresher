class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # Separate update_attribute because update_attributes require password validation
      user.activate
      log_in user
      flash[:success] = "Your account has been activated."
      redirect_to user
    else
      flash[:danger] = "We were unable to activate your account."
      redirect_to root_url
    end
  end
end
