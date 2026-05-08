class Api::MoviesController < ApplicationController
  # GET /movies
  def index
    @movies = Movie.all

    render json: @movies
  end

  # GET /movies/1
  def show
    @movie = Movie.find(params.expect(:id))

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
        title: showtime.movie.title,
        genre: showtime.movie.genre,
        duration: showtime.movie.duration,
        theater: showtime.theater.name,
        price: showtime.theater.price_for_day(time),
        showtime: time
      }
    end

    render json: result
  end
end
