class MoviesController < ApplicationController


  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  
  def index
    @all_ratings = Movie.movie_ratings
    @sort = nil
    @movies = Movie.all
    
    # The change in parameters always supersedes the session then hydrates the session right afterwards, else go straight to the session parameters if no paramters were changed
    # @ratings should be a hash so that it can get the corresponding key to check/uncheck the boxes in the index HAML file 
    
    if params[:ratings]
      @ratings = params[:ratings]
      session[:ratings] = @ratings
    elsif session[:ratings]
      @ratings = session[:ratings]
    # If no session params for rating then i need to establish all the checkboxes be automatically checked to pass to HAML
    else
      @ratings = Hash.new
      @all_ratings = Movie.movie_ratings
    # Creating a ratings dictionary in order to determine which key value pairs are present in the INDEX HAML
      @all_ratings.each do |rating|
        @ratings[rating] = true
      end
    end
    
    if params[:sort] # if there is a sort param after clicking the links on the table, supersedes and hydrates the session 
      @sort = params[:sort]
      session[:sort] = @sort
    elsif session[:sort]
      @sort = session[:sort]
    end
    
  ``if @ratings or @sort
      flash.keep
    
    # This is the sorting and filtering portion of the controller, it takes the @ratings and @sort variables stored above and applies them to the Active Record!
    # I check for both first, then each indvidually, @rating is always present, without it the table would show nothing which is trivial
    
    if @ratings and @sort
      session[:ratings] = @ratings
      session[:sort] = @sort
      @movies = Movie.where(rating: session[:ratings].keys).order(session[:sort])
    elsif @ratings
      session[:ratings] = @ratings
      @movies = Movie.where(rating: session[:ratings].keys)
    elsif @sort
      session[:sort] = @sort
      @movies = Movie.order(session[:sort])
    end
    
  end
  
  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
