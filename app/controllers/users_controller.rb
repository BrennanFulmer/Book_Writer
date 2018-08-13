
class UsersController < ApplicationController
  use Rack::Flash

  get "/signup" do
    @user = current_user
    redirect_if_already_logged_in
    erb :"/users/new"
  end

  post "/signup" do
    @user = User.new(params[:user])

    if @user.save
      session[:user_id] = @user.id
      redirect "/users/#{@user.slug}/books"
    else
      flash[:message] = "Error: Invalid Username and/or Password"
      redirect "/signup"
    end
  end

  post "/login" do
    @user = User.find_by(username: params[:username])

    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect "/users/#{@user.slug}/books"
    else
      flash[:message] = "Error: Invalid Username and/or Password"
      redirect "/"
    end
  end

  get "/logout" do
    session.clear
    redirect "/books"
  end

end
