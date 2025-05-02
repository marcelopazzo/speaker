class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    if user
      session[:user_id] = user.id
      redirect_to keyboard_path, notice: "Successfully signed in!"
    else
      redirect_to root_path, alert: "Authentication failed!"
    end
  end

  def failure
    error_type = params[:message]
    error_description = params[:error_description]

    case error_type
    when "access_denied"
      redirect_to root_path, alert: "You denied access to your Google account. Please try again and accept the permissions."
    when "invalid_credentials"
      redirect_to root_path, alert: "Invalid credentials. Please try again."
    when "invalid_request"
      redirect_to root_path, alert: "Invalid request. Please try again."
    else
      redirect_to root_path, alert: "Authentication failed: #{error_description || 'Unknown error'}"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Successfully signed out!"
  end
end
