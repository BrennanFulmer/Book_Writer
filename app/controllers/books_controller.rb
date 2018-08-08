
class BooksController < ApplicationController
  use Rack::Flash

  before "/books*" do
    @user = current_user
  end

  get "/books" do
    @books = Book.all
    erb :"/books/index"
  end

  get "/books/new" do
    if @user
      erb :"/books/new"
    else
      flash[:message] = "You Must Be Signed In To Create A Book"
      redirect "/"
    end
  end

  post "/books" do
# TODO syntax for actually getting error - @new_book.errors.full_messages
# TODO block creation of a book named new
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
      @your_book = @user.id == @book.user_id if @user
      erb :"/books/show"
    else
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    end
  end

  get "/books/:title/edit" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book

    if @book && @your_book
      erb :"/books/edit"
    elsif @book
      flash[:message] = "You Don't Have Permission to Edit '#{params[:title]}'"
      redirect "/books/#{@book.slug}"
    else
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    end
  end

  post "/books/:id" do
    @book = Book.find(params[:id])
    @book.update(title: params[:title])
    redirect "/books/#{@book.slug}"
  end

  delete "/books/:id" do
# TODO handle associated chapter deletion
    @book = Book.find(params[:id])
    @your_book = @user.id == @book.user_id if @user

    if @your_book
      @book.delete
      erb :"/books/delete"
    else
      flash[:message] = "You Can't Delete A Book That's Not Yours"
      redirect "/books"
    end
  end

  get "/users/:author/books" do
    @author = User.find_by_slug(params[:author])
    @user = current_user

    if @author
      @your_books = @author == @user
      erb :"/books/users_books"
    else
      flash[:message] = "Unable To Show Books By #{params[:author]}"
      redirect "/books"
    end
  end

end
