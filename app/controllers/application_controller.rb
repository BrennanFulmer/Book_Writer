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

end
