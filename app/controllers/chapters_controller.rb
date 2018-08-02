
class ChaptersController < ApplicationController
  use Rack::Flash

  get "/:book_title/new_chapter" do
    @book = Book.find_by_slug(params[:book_title])
    @user = current_user
    @your_book = @user.id == @book.user_id if @user

    if @book && @your_book
      erb :"/chapters/new"
    elsif !@book
      flash[:message] = "No '#{params[:title]}' Book Found"
      redirect "/books"
    else
      if @user
        flash[:message] = "You Can't Add Chapters To Someone Elses Books"
        redirect "/books/by-user/#{@user.username}"
      else
        flash[:message] = "You Have To Be Signed In To Add Chapters"
        redirect "/"
      end
    end
  end

  post "/chapters" do
    @book = Book.find_by(id: params[:chapter][:book_id])
    @chapter = Chapter.new(params[:chapter])

    if @book.unique_ordinal?(@chapter) && @chapter.save
      redirect "/#{@book.slug}/#{@chapter.ordinal}"
    else
      flash[:message] = "Invalid Chapter Title Or Number"
      redirect "/#{@book.slug}/new_chapter"
    end
  end

  get "/:book_title/:chapter_ordinal" do
    
  end

  get "/:book_title/:chapter_ordinal/write" do
  end

  get "/:book_title/:chapter_ordinal/edit" do
  end

  get "/:book_title/:chapter_ordinal/delete" do
  end

end
