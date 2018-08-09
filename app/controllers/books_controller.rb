
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
      flash[:message] = "Error: You Must Be Signed In To Create A Book"
      redirect "/"
    end
  end

  post "/books" do
    @new_book = Book.new(title: params[:title], user_id: session[:user_id])

    if @new_book.save
      redirect "/books/#{@new_book.slug}"
    else
      flash[:message] = "Error: Book Title '#{@new_book.title}' Is Invalid"
      redirect "/books/new"
    end
  end

  get "/books/:title" do
    if @book = Book.find_by_slug(params[:title])
      @your_book = @user.id == @book.user_id if @user
      @author = User.find(@book.user_id) unless @your_book
      erb :"/books/show"
    else
      flash[:message] = "Error: No '#{params[:title]}' Book Found"
      redirect "/books"
    end
  end

  get "/books/:title/edit" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book

    if !@book
      flash[:message] = "Error: No '#{params[:title]}' Book Found"
      redirect "/books"
    elsif !@user
      flash[:message] = "Error: Sign In To Edit Books"
      redirect "/"
    elsif !@your_book
      flash[:message] = "Error: You Can't Edit Someone Else's Book"
      redirect "/users/#{@user.slug}/books"
    else
      erb :"/books/edit"
    end
  end

  post "/books/:id" do
    @book = Book.find(params[:id])
    if @book.update(title: params[:title])
      redirect "/books/#{@book.slug}"
    else
      flash[:message] = "Error: Can't Update Book Title To '#{params[:title]}'"
      redirect "/books/#{Book.find(params[:id]).slug}/edit"
    end
  end

  delete "/books/:id" do
    @book = Book.find(params[:id])
    @your_book = @user.id == @book.user_id if @user && @book

    if @book && @your_book
      if !@book.chapters.empty?
        @chapters = @book.chapters
        @book.chapters.each do |chapter|
          chapter.delete
        end
      end
      @book.delete
      erb :"/books/delete"
    elsif !@book
      flash[:message] = "Error: The Book You Attempted To Delete Was Not Found"
      redirect "/books"
    elsif !@your_book
      flash[:message] = "Error: You Can't Delete A Book That's Not Yours"
      redirect "/users/#{@user.slug}/books"
    else
      flash[:message] = "Error: Sign In To Delete Books"
      redirect "/"
    end
  end

  get "/users/:author/books" do
    @author = User.find_by_slug(params[:author])
    @user = current_user

    if @author
      @your_books = @author == @user
      erb :"/books/users_books"
    else
      flash[:message] = "Error: Unable To Show Books By '#{params[:author]}'"
      redirect "/books"
    end
  end

end
