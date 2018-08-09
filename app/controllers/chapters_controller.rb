
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
      flash[:message] = "Error: No '#{params[:title]}' Book Found"
      redirect "/books"
    else
      if @user
        flash[:message] = "Error: You Can't Add Chapters To Someone Elses Books"
        redirect "/users/#{@user.username}/books"
      else
        flash[:message] = "Error: You Have To Be Signed In To Add Chapters"
        redirect "/"
      end
    end
  end

  post "/books/:id/chapters" do
    @chapter = Chapter.new(params[:chapter])
    @book = Book.find(params[:id])

    if unique_name?(@chapter, @book) && unique_ordinal?(@chapter, @book) && @chapter.save
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}"
    else
      flash[:message] = "Error: Invalid Chapter Title Or Number"
      redirect "/books/#{@book.slug}/chapters/new"
    end
  end

  get "/books/:title/chapters/:ordinal/write" do
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    @your_book = @user.id == @book.user_id if @user && @book

    if !@book
      if @user
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    elsif !@chapter
      flash[:message] = "Error: Chapter '#{params[:ordinal]}' Not Found"
      redirect "/books/#{@book.slug}"
    elsif !@your_book
      if @user
        flash[:message] = "Error: You Can't Write Someone Else's Chapter"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: You Must Sign In To Write A Chapter"
        redirect "/"
      end
    else
      erb :"/chapters/write"
    end
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
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    @your_book = @user.id == @book.user_id if @user && @book

    if !@book
      if @user
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    elsif !@chapter
      flash[:message] = "Error: Chapter '#{params[:ordinal]}' Not Found"
      redirect "/books/#{@book.slug}"
    elsif !@your_book
      if @user
        flash[:message] = "Error: You Can't Edit Someone Else's Chapter"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: You Must Sign In To Edit A Chapter"
        redirect "/"
      end
    else
      erb :"/chapters/edit"
    end
  end

  post "/books/:b_id/chapters/:c_id/edit" do
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])

    if unique_name?(@chapter, @book) && unique_ordinal?(@chapter, @book) && @chapter.update(params[:chapter])
      redirect "/books/#{@book.slug}/chapters/#{@chapter.ordinal}"
    else
      flash[:message] = "Error: Submission Invalid"
      redirect "/books/#{@book.slug}/chapters/#{Chapter.find(params[:c_id]).ordinal}/edit"
    end
  end

  get "/books/:title/chapters/:ordinal/modify_content" do
    @book = Book.find_by_slug(params[:title])
    @chapter = Chapter.find_by(ordinal: params[:ordinal])
    @your_book = @user.id == @book.user_id if @user && @book

    if !@book
      if @user
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    elsif !@chapter
      flash[:message] = "Error: Chapter '#{params[:ordinal]}' Not Found"
      redirect "/books/#{@book.slug}"
    elsif !@user
      flash[:message] = "Error: You Must Be Signed In To Modify A Chapters Contents"
      redirect "/"
    elsif !@your_book
      flash[:message] = "Error: You Can't Modify The Contents Of Someone Else's Chapter"
      redirect "/users/#{@user.slug}/books"
    elsif !@chapter.content
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

  delete "/books/:b_id/chapters/:c_id/delete" do
    @book = Book.find(params[:b_id])
    @chapter = Chapter.find(params[:c_id])

    if !@book
      if @user
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    elsif !@chapter
      flash[:message] = "Error: Chapter '#{params[:ordinal]}' Not Found"
      redirect "/books/#{@book.slug}"
    else
      @chapter.delete
      erb :"/chapters/delete"
    end
  end

  get "/books/:title/chapters/reorder" do
    @book = Book.find_by_slug(params[:title])
    @your_book = @user.id == @book.user_id if @user && @book

    if !@book
      if @user
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    elsif @book.chapters.empty? || @book.chapters.length == 1
      flash[:message] = "Error: Not Enough Chapters To Reorder"
      redirect "/books/#{@book.slug}"
    elsif !@user
      flash[:message] = "Error: You Must Be Signed In To Reorder A Books Chapters"
      redirect "/"
    elsif !@your_book
      flash[:message] = "Error: You Can't Modify The Contents Of Someone Else's Chapter"
      redirect "/users/#{@user.slug}/books"
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
    @chapter = Chapter.find_by(ordinal: params[:ordinal])

    if !@book
      if @user
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/users/#{@user.slug}/books"
      else
        flash[:message] = "Error: No '#{params[:title]}' Book Found"
        redirect "/books"
      end
    elsif !@chapter
      flash[:message] = "Error: Chapter '#{params[:ordinal]}' Not Found"
      redirect "/books/#{@book.slug}"
    else
      @your_book = @user.id == @book.user_id if @user && @book
      @author = User.find(@book.user_id) unless @your_book
      erb :"/chapters/show"
    end
  end

end
