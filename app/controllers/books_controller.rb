
class BooksController < ApplicationController
  use Rack::Flash

  get "/books" do
    @books = Book.all
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

end
