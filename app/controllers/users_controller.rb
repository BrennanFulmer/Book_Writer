
class UsersController < ApplicationController
  use Rack::Flash

  get "/signup" do
    if user = current_user
      flash[:message] = "Error: Your Already Logged In"
      redirect "/users/#{user.slug}/books"
    else
      erb :"/users/new"
    end
  end

  post "/signup" do
    new_user = User.new(params[:user])

    if new_user.save
      session[:user_id] = new_user.id
      redirect "/users/#{new_user.slug}/books"
    else
      flash[:message] = "Error: Invalid Username and/or Password"
      redirect "/signup"
    end
  end

  post "/login" do
    user = User.find_by(username: params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/users/#{user.slug}/books"
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
