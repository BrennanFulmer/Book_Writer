require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET')
  end

  get "/" do
    if user = current_user
      flash[:message] = "Error: Your Already Logged In"
      redirect "/users/#{user.slug}/books"
    else
      erb :index
    end
  end

  helpers do
    def current_user
      if session[:user_id]
        User.find(session[:user_id])
      end
    end

    def unique_ordinal?(chapter, book)
      book.chapters.all? do |chapter|
        chapter.ordinal != new_chapter.ordinal
      end
    end

    def unique_name?(chapter, book)
      book.chapters.all? do |chapter|
        chapter.name != new_chapter.name
      end
    end
  end

end
