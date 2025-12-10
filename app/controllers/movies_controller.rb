class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show update destroy ]

  # GET /movies
  def index
    @movies = Movie.all

    render json: @movies
  end

  # GET /movies/1
  def show
    render json: @movie
  end

  # GET /movies/search?params=value
  # Get the available movies.
  # Parameters: theaters, day and time.
  # In each movie I'll have the theaters with the cheapest price (depending on the day) and the datetimes.
  def search
    theaters_param = params[:theaters]
    datetime_param = params[:datetime]

    # Validation
    if datetime_param.blank? || theaters_param.blank?
      render json: {
        error: "Missing required parameters: date and time"
      }, status: :bad_request
    end

    begin
      datetime = DateTime.parse(datetime_param)
    rescue ArgumentError => e
      render json: {
        error: "Invalid datetime format: #{e.message}"
      }, status: :bad_request
    end

    # Query
    # ToDo -> Move to model?
    showtimes = Showtime.includes(:movie, :theater)
      .where("DATE(showtimes.showtime) = ?", datetime.to_date)
      .where("showtimes.showtime >= ?", datetime)
      .where(theater: { name: theaters_param })

    # Add price
    # ToDo -> Move to model?
    # Blueprinter?
    result = showtimes.map do |showtime|
      time = showtime.showtime
      {
        name: showtime.movie.name,
        genre: showtime.movie.genre,
        duration: showtime.movie.duration,
        theater: showtime.theater.name,
        price: showtime.theater.price_for_day(time),
        showtime: time
      }
    end

    render json: result
  end

  # POST /movies
  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      render json: @movie, status: :created, location: @movie
    else
      render json: @movie.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /movies/1
  def update
    if @movie.update(movie_params)
      render json: @movie
    else
      render json: @movie.errors, status: :unprocessable_content
    end
  end

  # DELETE /movies/1
  def destroy
    @movie.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.expect(movie: [ :name, :duration, :genre ])
    end
end
