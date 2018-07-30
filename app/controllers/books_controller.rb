
class BooksController < ApplicationController
  use Rack::Flash

  get "/books" do
    @books = Book.all
    @user = current_user
    erb :"/books/index"
  end

  get "/books/by-user/:username" do
    @user = User.find_by(username: params[:username]) ||
    User.find_by_slug(params[:username])
    @authenticated = logged_in?
    @your_books = @user == current_user
    erb :"/books/by_user"
  end

  get "/books/new" do
    if logged_in?
      @user = current_user
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

  get "/books/:title" do
    @book = Book.find_by(title: params[:title]) ||
    Book.find_by_slug(params[:title])

    if @book
      @user = current_user
      @your_book = @user.id == @book.user_id if @user
      erb :"/books/show"
    else
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    end
  end

end
