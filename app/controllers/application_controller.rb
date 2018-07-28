require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET')
  end

  get "/" do
    erb :index
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

  helpers do
    def logged_in?
      session[:user_id] != nil
    end

    def current_user
      User.find(session[:user_id])
    end
  end

end
