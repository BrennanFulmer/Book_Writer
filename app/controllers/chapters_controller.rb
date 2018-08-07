
class ChaptersController < ApplicationController
  use Rack::Flash

  before "/books*" do
    @user = current_user
  end

  get "/books/:title/chapters/new" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book

    if @book && @your_book
      erb :"/chapters/new"
    elsif !@book
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    else
      if @user
        flash[:message] = "You Can't Add Chapters To Someone Elses Books"
        redirect "/users/#{@user.username}/books"
      else
        flash[:message] = "You Have To Be Signed In To Add Chapters"
        redirect "/"
      end
    end
  end

  post "/books/:id/chapters" do
    @chapter = Chapter.new(params[:chapter])
    @book = Book.find(params[:id])

    if Chapter.unique_ordinal?(@chapter) && @chapter.save
      redirect "/#{@book.slug}/#{@chapter.ordinal}"
    else
      flash[:message] = "Invalid Chapter Title Or Number"
      redirect "/books/#{@book.slug}/chapters/new"
    end
  end

  get "/books/:title/chapters/:ordinal" do
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    erb :"/chapters/show"
  end

  get "/books/:title/chapters/:ordinal/write" do
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    erb :"/chapters/write"
  end

  post "/books/:b_id/chapters/:c_id/write" do
# TODO needs to block submission if empty
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])

    if @chapter.content
      @chapter.content += "\n\t#{params[:content]}"
    else
      @chapter.content = params[:content]
    end
    @chapter.save
    redirect "/#{@book.slug}/#{@chapter.ordinal}"
  end

  get "/books/:title/chapters/:ordinal" do
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    erb :"/chapters/edit"
  end

  post "/books/:b_id/chapters/:c_id" do
# TODO needs to block submission if empty
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])
    @chapter.update(params[:chapter])
    @chapter.save
    redirect "/#{@book.slug}/#{@chapter.ordinal}"
  end

  get "/books/:title/chapters/:ordinal/modify_content" do
# TODO should redirect if there is no content
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    erb :"/chapters/modify_content"
  end

  post "/books/:b_id/chapters/:c_id/modify_content" do
# TODO needs to block submission if empty
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])
    @chapter.content = params[:content]
    @chapter.save
    redirect "/#{@book.slug}/#{@chapter.ordinal}"
  end

  delete "/books/:b_id/chapters/:c_id" do
    @chapter = Chapter.find(params[:c_id])
    @chapter.delete
    erb :"/chapters/delete"
  end

  get "/books/:title/chapters/reorder" do
=begin
  TODO redirect if book doesn't exist, has no chapters, not logged in,
   not your book
=end
    @book = Book.find_by_slug(params[:title])
    erb :"/books/reorder"
  end

  post "/books/:id/chapters/reorder" do
# TODO handle duplicate ordinal submission, or lack of ordinal input
    @book = Book.find(params[:id])
    new_chapter_order = params[:chapters].to_a

    new_chapter_order.each do |chapter|
      current_chapter = Chapter.find_by(name: chapter[0])
      current_chapter.ordinal = chapter[1][0]
      current_chapter.save
    end
    redirect "books/#{@book.slug}"
  end

end
