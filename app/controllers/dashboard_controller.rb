# frozen_string_literal: true

class DashboardController < ApplicationController
  include Authentication

  def index
    @theater_count = Theater.count
    @movie_count = Movie.count
    @recent_theaters = Theater.latest(5)
    @recent_movies = Movie.latest(5)
    @recent_showtimes = Showtime.includes(:movie, :theater).order(created_at: :desc).limit(5)
  end
end
