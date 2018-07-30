
class BooksController < ApplicationController
  use Rack::Flash

  get "/books" do
    @books = Book.all
    @authenticated = logged_in?

    erb :"/books/index"
  end

  get "/books/by-user/:username" do
    @user = User.find_by(username: params[:username])

    @users_books = Book.all.collect do |book|
      book if book.user == @user
    end

    @users_books.compact!
    @authenticated = logged_in?
    @your_books = @user == current_user

    erb :"/books/by_user"
  end

  get "/books/new" do
    if logged_in?
      erb :"/books/new"
    else
      flash[:message] = "You Must Be Signed In To Create A Book"
      redirect "/"
    end
  end

  post "/books" do
    @new_book = Book.new(title: params[:book][:title], user_id: session[:user_id])

    if @new_book.save
      redirect "/books/#{@new_book.slug}"
    else
      flash[:message] = "Book Title '#{@new_book.title}' Is Invalid"
      redirect "/books/new"
    end
  end

  get "/books/:slug" do
    binding.pry
    @book = Book.find_by_slug(params[:slug])
    erb :"/books/show"
  end

end
