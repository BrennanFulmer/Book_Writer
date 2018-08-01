
class BooksController < ApplicationController
  use Rack::Flash

  get "/books" do
    @books = Book.all
    @user = current_user
    erb :"/books/index"
  end

  get "/books/by-user/:username" do
    @user = User.find_by_slug(params[:username])

    if @user
      @authenticated = logged_in?
      @your_books = @user == current_user
      erb :"/books/by_user"
    else
      flash[:message] = "Unable To Show Books By #{params[:username]}"
      redirect "/books"
    end
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
    @new_book = Book.new(title: params[:title], user_id: session[:user_id])

    if @new_book.save
      redirect "/books/#{@new_book.slug}"
    else
      flash[:message] = "Book Title '#{@new_book.title}' Is Invalid"
      redirect "/books/new"
    end
  end

  get "/books/:title" do
    @book = Book.find_by_slug(params[:title])

    if @book
      @user = current_user
      @your_book = @user.id == @book.user_id if @user
      erb :"/books/show"
    else
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    end
  end

  get "/books/:title/edit" do
    @book = Book.find_by_slug(params[:title])
    @user = current_user
    @your_book = @user.id == @book.user_id if @user

    if @book && @your_book
      erb :"/books/edit"
    elsif @book
      flash[:message] = "You Don't Have Permission to Edit '#{params[:title]}'"
      redirect "/books/<%= @book.slug %>"
    else
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    end
  end

  post "/books/:id" do
    @book = Book.find_by(id: params[:id])
    @book.update(title: params[:title])
    redirect "books/#{@book.slug}"
  end

  delete "/books/:id/delete" do
    # TODO handle associated chapter deletion
    @book = Book.find_by(id: params[:id])
    @user = current_user
    @your_book = @user.id == @book.user_id if @user

    if @your_book
      @book.delete
      erb :"/books/delete"
    else
      flash[:message] = "You Can't Delete A Book That's Not Yours"
      redirect "/books"
    end
  end

end
