
class BooksController < ApplicationController
  use Rack::Flash

  before do
    @user = current_user
  end

  get "/books" do
    @books = Book.all
    erb :"/books/index"
  end

  get "/books/new" do
    redirect_if_not_logged_in
    erb :"/books/new"
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
    @book = Book.find_by_slug(params[:title])
    redirect_if_no_book
    @your_book = @user.id == @book.user_id if @user
    @author = User.find(@book.user_id) if !@your_book
    erb :"/books/show"
  end

  get "/books/:title/edit" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book
    redirect_if_not_logged_in
    redirect_if_no_book
    redirect_if_not_your_book
    erb :"/books/edit"
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

    if !@book.chapters.empty?
      @chapters = @book.chapters
      @book.chapters.each do |chapter|
        chapter.destroy
      end
    end
    @book.destroy
    erb :"/books/delete"
  end

  get "/users/:author/books" do
    if @author = User.find_by_slug(params[:author])
      @your_books = @author == @user
      erb :"/books/users_books"
    else
      flash[:message] = "Error: Unable To Show Books By '#{params[:author]}'"
      redirect "/books"
    end
  end

end
