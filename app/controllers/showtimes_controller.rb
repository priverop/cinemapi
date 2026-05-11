# frozen_string_literal: true

class ShowtimesController < DashboardController
  before_action :set_showtime, only: %i[edit update destroy]

  def new
    @showtime = Showtime.new(movie_id: params[:movie_id], theater_id: params[:theater_id])
    @movies = Movie.order(:title)
    @theaters = Theater.order(:name)
  end

  def create
    @showtime = Showtime.new(showtime_params)

    if @showtime.save
      redirect_to movie_path(@showtime.movie), notice: "Showtime was successfully created."
    else
      @movies = Movie.order(:title)
      @theaters = Theater.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @movies = Movie.order(:title)
    @theaters = Theater.order(:name)
  end

  def update
    if @showtime.update(showtime_params)
      redirect_to movie_path(@showtime.movie), notice: "Showtime was successfully updated."
    else
      @movies = Movie.order(:title)
      @theaters = Theater.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    movie = @showtime.movie
    @showtime.destroy!
    redirect_to movie_path(movie), notice: "Showtime was successfully deleted.", status: :see_other
  end

  private

  def set_showtime
    @showtime = Showtime.find(params[:id])
  end

  def showtime_params
    params.require(:showtime).permit(:movie_id, :theater_id, :showtime, :language)
  end
end
