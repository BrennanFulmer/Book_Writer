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

    def unique_ordinal?(check_chapter, book)
      book.chapters.all? do |chapter|
        chapter.ordinal != check_chapter.ordinal
      end
    end

    def unique_name?(check_chapter, book)
      book.chapters.all? do |chapter|
        chapter.name != check_chapter.name
      end
    end

    def find_books_chapter_by_ordinal(ordinal, book)
      target_ordinal = ordinal.to_i

      book.chapters.detect do |chapter|
        chapter.ordinal == target_ordinal
      end
    end
  end

end
