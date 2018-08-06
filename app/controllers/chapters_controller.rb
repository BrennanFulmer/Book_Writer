
class ChaptersController < ApplicationController
  use Rack::Flash

=begin
  before "/chapters*" do
    # something
  end
=end

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
    @chapter = Chapter.new(params[:chapter])
    @book = Book.find_by(id: params[:chapter][:book_id])

    if Chapter.unique_ordinal?(@chapter) && @chapter.save
      redirect "/#{@book.slug}/#{@chapter.ordinal}"
    else
      flash[:message] = "Invalid Chapter Title Or Number"
      redirect "/#{@book.slug}/new_chapter"
    end
  end

  get "/:book_title/:chapter_ordinal" do
    @book = Book.find_by_slug(params[:book_title])
    @chapter = Chapter.find_by(ordinal: params[:chapter_ordinal])
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

  get "/books/:title/chapters/:ordinal/edit" do
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    erb :"/chapters/edit"
  end

  post "/books/:b_id/chapters/:c_id/edit" do
# TODO needs to block submission if empty
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])
    @chapter.update(params[:chapter])
    @chapter.save
    redirect "/#{@book.slug}/#{@chapter.ordinal}"
  end

  get "/books/:title/chapters/:ordinal/modify" do
# TODO should redirect if there is no content
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    erb :"/chapters/modify"
  end

  post "/books/:b_id/chapters/:c_id/modify" do
# TODO needs to block submission if empty
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])
    @chapter.content = params[:content]
    @chapter.save
    redirect "/#{@book.slug}/#{@chapter.ordinal}"
  end

  delete "/books/:b_id/chapters/:c_id/delete" do
    @chapter = Chapter.find(params[:c_id])
    @chapter.delete
    erb :"/chapters/delete"
  end

end
