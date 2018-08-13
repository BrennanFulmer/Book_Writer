require 'rack-flash'

class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, ENV.fetch('SESSION_SECRET')
  end

  get "/" do
    @user = current_user
    redirect_if_already_logged_in
    erb :index
  end

  helpers do
    def current_user
      if session[:user_id]
        User.find(session[:user_id])
      end
    end

    def unique_ordinal?(chapter_ordinal, book)
      chapter_number = chapter_ordinal.to_i
      book.chapters.all? do |chapter|
        chapter.ordinal != chapter_number
      end
    end

    def unique_name?(chapter_name, book)
      book.chapters.all? do |chapter|
        chapter.name != chapter_name
      end
    end

    def find_books_chapter_by_ordinal(ordinal, book)
      target_ordinal = ordinal.to_i

      book.chapters.detect do |chapter|
        chapter.ordinal == target_ordinal
      end
    end

    def redirect_if_already_logged_in
      if @user
        flash[:message] = "Error: Your Already Logged In"
        redirect "/users/#{@user.slug}/books"
      end
    end

    def redirect_if_not_logged_in
      if !@user
        flash[:message] = "Error: Log In To Do That"
        redirect "/"
      end
    end

    def redirect_if_no_book
      if !@book
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    end

    def redirect_if_not_your_book
      if !@your_book
        flash[:message] = "Error: You Can't Change Someone Else's Book"
        redirect "/users/#{@user.slug}/books"
      end
    end

    def redirect_if_no_chapter
      if !@chapter
        flash[:message] = "Error: Chapter '#{params[:ordinal]}' Not Found"
        redirect "/books/#{@book.slug}"
      end
    end

  end

end
