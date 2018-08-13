
class ChaptersController < ApplicationController
  use Rack::Flash

  before do
    @user = current_user
  end

  get "/books/:title/chapters/new" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book
    redirect_if_not_logged_in
    redirect_if_no_book
    redirect_if_not_your_book
    erb :"/chapters/new"
  end

  post "/books/:id/chapters" do
    @chapter = Chapter.new(params[:chapter])
    @book = Book.find(params[:id])

    if unique_name?(params[:chapter][:name], @book) &&
       unique_ordinal?(params[:chapter][:ordinal], @book) &&
       @chapter.save
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}"
    else
      flash[:message] = "Error: Invalid Chapter Title Or Number"
      redirect "/books/#{@book.slug}/chapters/new"
    end
  end

  get "/books/:title/chapters/:ordinal/write" do
    @book = Book.find_by_slug(params[:title])
    @chapter = find_books_chapter_by_ordinal(params[:ordinal], @book)
    @your_book = @user.id == @book.user_id if @user && @book
    redirect_if_not_logged_in
    redirect_if_no_book
    redirect_if_no_chapter
    redirect_if_not_your_book
    erb :"/chapters/write"
  end

  post "/books/:b_id/chapters/:c_id/write" do
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])

    unless params[:content].strip == ""
      if @chapter.content
        @chapter.content += "\n#{params[:content]}"
        @chapter.save
      else
        @chapter.update(content: params[:content])
      end
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}"
    else
      flash[:message] = "Error: Invalid Submission"
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}/write"
    end
  end

  get "/books/:title/chapters/:ordinal/edit" do
    @book = Book.find_by_slug(params[:title])
    @chapter = find_books_chapter_by_ordinal(params[:ordinal], @book)
    @your_book = @user.id == @book.user_id if @user && @book
    redirect_if_not_logged_in
    redirect_if_no_book
    redirect_if_no_chapter
    redirect_if_not_your_book
    erb :"/chapters/edit"
  end

  post "/books/:b_id/chapters/:c_id" do
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])

    if unique_name?(params[:chapter][:name], @book) &&
       unique_ordinal?(params[:chapter][:ordinal], @book) &&
       @chapter.update(params[:chapter])
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}"
    else
      flash[:message] = "Error: Submission Invalid"
      @chapter = Chapter.find(params[:c_id])
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}/edit"
    end
  end

  get "/books/:title/chapters/:ordinal/modify_content" do
    @book = Book.find_by_slug(params[:title])
    @chapter = find_books_chapter_by_ordinal(params[:ordinal], @book)
    @your_book = @user.id == @book.user_id if @user && @book
    redirect_if_not_logged_in
    redirect_if_no_book
    redirect_if_no_chapter
    redirect_if_not_your_book

    if !@chapter.content
      flash[:message] = "Error: There Is No Content To Modify"
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}/write"
    else
      erb :"/chapters/modify_content"
    end
  end

  post "/books/:b_id/chapters/:c_id/modify_content" do
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])

    if params[:content].strip != ""
      @chapter.update(content: params[:content])
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}"
    else
      flash[:message] = "Error: Invalid Submission"
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}/modify_content"
    end
  end

  delete "/books/:b_id/chapters/:c_id" do
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])
    @chapter.destroy
    erb :"/chapters/delete"
  end

  get "/books/:title/chapters/reorder" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book
    redirect_if_not_logged_in
    redirect_if_no_book
    redirect_if_not_your_book

    if @book.chapters.empty? || @book.chapters.length == 1
      flash[:message] = "Error: Not Enough Chapters To Reorder"
      redirect "/books/#{@book.slug}"
    else
      erb :"/chapters/reorder"
    end
  end

  post "/books/:id/chapters/reorder" do
    @book = Book.find(params[:id])
    new_chapter_order = params[:chapters].to_a
    test_chapter_order = new_chapter_order.dup.transpose[1].flatten.uniq

    test_chapter_order.delete_if do |new_ordinal|
      new_ordinal.strip == "" ||
      new_ordinal.to_i == 0 ||
      new_ordinal.length > 2 ||
      new_ordinal[0] == "0"
    end

    if test_chapter_order == new_chapter_order.dup.transpose[1].flatten
      new_chapter_order.each do |chapter|
        current_chapter = Chapter.find_by(name: chapter[0])
        current_chapter.update(ordinal: chapter[1][0])
      end
      redirect "/books/#{@book.slug}"
    else
      flash[:message] = "Error: Invalid Chapter Order"
      redirect "/books/#{@book.slug}/chapters/reorder"
    end
  end

  get "/books/:title/chapters/:ordinal" do
    @book = Book.find_by_slug(params[:title])
    @chapter = find_books_chapter_by_ordinal(params[:ordinal], @book)
    @your_book = @user.id == @book.user_id if @user && @book
    @author = User.find(@book.user_id) if !@your_book
    redirect_if_no_book
    redirect_if_no_chapter
    erb :"/chapters/show"
  end

end
