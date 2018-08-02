require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET')
  end

  get "/" do
    if logged_in?
      flash[:message] = "Your Already Logged In"
      redirect "/books"
    else
      erb :index
    end
  end

  helpers do
    def logged_in?
      session[:user_id] != nil
    end

    def current_user
      if session[:user_id]
        User.find(session[:user_id])
      end
    end
  end

end
