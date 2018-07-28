
class UsersController < ApplicationController
  use Rack::Flash

  get "/signup" do
    erb :"/users/new"
  end

  post "/signup" do
    new_user = User.new(username: params[:username], password: params[:password])

    unique_username = User.all.all? do |user|
       new_user.username != user.username
    end

    if unique_username && new_user.save
      redirect "/books/by-user/#{new_user.username}"
    else
      flash[:message] = "Invalid Username and/or Password"
      redirect "/signup"
    end
  end

  post "/login" do
    user = User.find_by(username: params[:username])

    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/books/by-user/#{user.username}"
    else
      flash[:message] = "Invalid Username and/or Password"
      redirect "/"
    end
  end

  get "/logout" do
    session.clear
    redirect "/books"
  end

end
