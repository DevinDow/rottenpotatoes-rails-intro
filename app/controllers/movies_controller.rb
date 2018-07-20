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
    # nuke session
    if !params["clear"].nil?
      session.clear
    end

    # @all_ratings needed for View
    @all_ratings = Movie.all_ratings()
    
    # sort by column clicked
    if !params["sort"].nil?
      # save "sort" to session
      @sort = session[:sort] = params["sort"]
    elsif !session[:sort].nil?
      # redirect using session for "sort" parameter
      params["sort"] = session[:sort]
      flash.keep
      redirect_to movies_path(params)
      return
    end

    # filter by ratings
    if !params["ratings"].nil?
      @ratings_filter = session[:ratings] = params["ratings"].keys
    elsif session[:ratings].nil?
      @ratings_filter = session[:ratings] = @all_ratings
    else
      params["ratings"] = {}
      session[:ratings].each do |rating|
        params["ratings"][rating] = 1
      end
      flash.keep
      redirect_to movies_path(:sort => session[:sort], :ratings => params[:ratings])
      return
    end

    @movies = Movie.where(rating: @ratings_filter).order(@sort)
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
